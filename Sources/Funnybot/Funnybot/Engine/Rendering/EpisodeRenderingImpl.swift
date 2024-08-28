//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import SwiftUI
import AVFoundation
import Combine
import Foundation
import Schwifty

class EpisodeRenderingImpl: EpisodeRendering {
    @Inject var configStorage: ConfigStorageService
    @Inject var audioRendering: AudioRendering
    @Inject var sceneRendering: SceneRendering
    @Inject var paths: PathsUseCase
    @Inject var videosComposer: VideosToVideoComposer
    @Inject var sceneAssembler: RenderableSceneAssembler
    @Inject var postProcessing: VideoPostProcessingUseCase
    
    var handler: EpisodeRenderingHandler = { _ in }
    var renderedFrames: Int = 0
    var totalFrames: Int = 0
    var frameTime: TimeInterval = 1
    var scene: RenderableScene!
    var episode: Episode!
    let progressQueue = DispatchQueue(label: "EpisodeRenderingImpl", qos: .userInteractive)
    let tag = "EpisodeRenderingImpl"
    var startTime = Date()
    var disposables = Set<AnyCancellable>()
    
    func render(episode: Episode, handler: @escaping EpisodeRenderingHandler) async throws -> URL {
        prepareToStart(with: episode, handler: handler)
        scene = try await sceneAssembler.scene(for: episode)
        totalFrames = Int(scene.duration / frameTime)
        
        let chunks = try await renderChunks()
        
        handler(.saving)
        let muteVideo = try await videosComposer.compose(videos: chunks)
        let dubbedVideo = try await audioRendering.add(audios: scene.audios, to: muteVideo)
        let processedVideo = try await postProcessing.postProcess(source: dubbedVideo)
        
        let url = try moveToFinalLocation(source: processedVideo)
        prepareForCompletion()
        return url
    }
    
    func renderChunks() async throws -> [URL] {
        try await sceneRendering.render(scene) { [weak self] in
            self?.progressQueue.async { [weak self] in
                guard let self else { return }
                self.renderedFrames += 1
                handler(.rendering(rendered: self.renderedFrames, total: self.totalFrames))
            }
        }
    }
    
    func prepareToStart(with episode: Episode, handler: @escaping EpisodeRenderingHandler) {
        self.startTime = Date()
        self.episode = episode
        self.handler = handler
        updateConfig()
        renderedFrames = 0
        Logger.debug(tag, "Starting...")
        handler(.compiling)
    }
    
    func prepareForCompletion() {
        scene = nil
        episode = nil
        handler(.done)
        handler = { _ in }
        let elapsedTime = abs(startTime.timeIntervalSinceNow)
        let timeString = String(format: "%0.2f", elapsedTime)
        Logger.debug(tag, "Done! \(timeString)s")
    }
    
    func updateConfig() {
        frameTime = configStorage.current.frameTime
    }
    
    func moveToFinalLocation(source: URL) throws -> URL {
        let destination = finalUrl()
        try? FileManager.default.removeItem(at: destination)
        try FileManager.default.createIntermediateDirectories(toFile: destination)
        try FileManager.default.copyItem(at: source, to: destination)
        return destination
    }
    
    func finalUrl() -> URL {
        let timestamp = Date().string("DDD_HH_mm_ss")
        let filename = "episode_\(timestamp).mp4"
        
        return paths
            .videosFolder(for: episode)
            .appendingPathComponent(filename, conformingTo: .movie)
    }
}
