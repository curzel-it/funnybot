//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation
import Combine
import Funnyscript
import Schwifty
import SwiftUI

class RenderingViewModel: ObservableObject {  
    static var instances: [UUID: RenderingViewModel] = [:]
    
    @Published var episode: Episode = .init()
    @Published var configurations: [Config] = []
    @Published var hasVideos: Bool = false
    @Published var isRendering: Bool = false
    @Published var message: String?
    @Published var progress: Float?
    
    @Inject private var app: AppViewModel
    @Inject private var compiler: Funnyscript.Compiler
    @Inject private var parser: Funnyscript.Parser
    @Inject private var rendering: EpisodeRendering
    @Inject private var assets: AssetsProvider
    @Inject private var soundEffects: SoundEffectsProvider
    @Inject private var voices: VoiceSynthesizer
    @Inject private var episodeDubber: EpisodeDubberUseCase
    @Inject private var configStorage: ConfigStorageService
    @Inject private var paths: PathsUseCase
    @Inject private var subtitles: ScriptSubtitlesGenerationUseCase
    @Inject private var srtFormatter: SRTFormattingUseCase
    @Inject private var dubs: DubsStorage
    
    var config: Config {
        configStorage.current
    }
    
    var videosFolder: URL {
        paths.videosFolder(for: episode)
    }
    
    private let tag = "RenderingViewModel"
    private var disposables = Set<AnyCancellable>()
    
    init(episode: Episode) {
        RenderingViewModel.instances[episode.id] = self
        
        Task { @MainActor in
            setup(episode: episode)
        }
    }
    
    @MainActor
    func setup(episode: Episode) {
        guard episode != self.episode else { return }
        self.episode = episode
        loadConfigurations()
        checkExistingVideos()
    }
    
    func generateSubtitles() {
        Task {
            do {
                let subs = try await subtitles.subtitles(for: episode.script)
                let srt = srtFormatter.srt(for: subs)
                app.message(text: srt)
            } catch {
                Logger.error(tag, "Failed to generate subs: \(error)")
            }
        }
    }
    
    private func loadConfigurations() {
        Task { @MainActor in
            configurations = configStorage.all().sorted { $0.name < $1.name }
        }
    }
    
    private func setMessage(_ message: String?) {
        Task { @MainActor in
            self.message = message
        }
    }
    
    private func setProgress(_ progress: Float?) {
        Task { @MainActor in
            self.progress = progress
        }
    }
    
    func onAppear() {
        loadConfigurations()
    }
    
    func start(with renderConfig: Config) async {
        setRendering(true)
        await configStorage.setCurrent(config: renderConfig)
        assets.reloadAssets(with: renderConfig)
        soundEffects.reloadAssets(with: renderConfig)
                
        do {
            try await dubEpisode()
            checkExistingVideos()
            let url = try await renderEpisode()
            open(renderedVideo: url)
            app.message(text: "Rendering Completed!")
        } catch {
            app.message(text: "Got an error: \(error)")
        }
        setRendering(false)
        setMessage(nil)
        setProgress(nil)
        checkExistingVideos()
    }
    
    private func renderEpisode() async throws -> URL {
        try await rendering.render(episode: episode) { [weak self] state in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.setMessage("\(state.description)...")
                self.setProgress(state.progress)
            }
        }
    }
    
    func open(renderedVideo url: URL) {
        url.visit()
        url.deletingLastPathComponent().visit()
    }
    
    func openVideosFolder() {
        videosFolder.visit()
    }
    
    @MainActor
    func deleteAllVideos() {
        FileManager.default
            .filesRecursively(from: videosFolder)
            .filter { $0.lastPathComponent.contains("mp4") }
            .forEach { try? FileManager.default.removeItem(at: $0) }
        checkExistingVideos()
    }
    
    private func dubEpisode() async throws {
        setMessage("Dubbing...")
        try await episodeDubber.dubAllLines(of: episode) { [weak self] progress in
            Task { @MainActor [weak self] in
                self?.setProgress(progress)
            }
        }
    }
        
    func checkExistingVideos() {
        Task { @MainActor in
            hasVideos = FileManager.default.fileExists(at: videosFolder)
        }
    }
    
    private func setRendering(_ value: Bool) {
        Task { @MainActor in
            isRendering = value
        }
    }
}
