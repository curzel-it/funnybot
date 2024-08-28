//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import AskGpt
import Combine
import Funnyscript
import Schwifty
import SwiftUI
import Swinject

class ConfigViewModel: ObservableObject {
    @Inject private var app: AppViewModel
    @Inject private var storage: ConfigStorageService
    
    weak var tab: TabViewModel?
    
    let config: Config
    
    @Published var assetsFolder: URL?
    @Published var dubsFolder: URL?
    @Published var videosFolder: URL?
    @Published var name: String
    @Published var fps: String
    @Published var framesPerChunk: String
    @Published var cameraTransitionDuration: String
    @Published var animationsFps: String
    @Published var sceneSize: SceneSize
    @Published var videoResolution: VideoResolution
    @Published var cameraInsets: String = ""
    @Published var cameraMode: CameraMode
    @Published var autoCharacterPlacement: Bool
    @Published var autoTurnToAction: Bool
    @Published var yMultiplierVerticalMid: String
    @Published var renderingSlots: String
    @Published var renderingMode: SceneRenderingMode
    @Published var voiceEngine: VoiceEngine
    @Published var language: String
        
    private let tag = "ConfigViewModel"
    private var disposables = Set<AnyCancellable>()
    
    init(config: Config) {
        self.config = config
        name = config.name
        fps = "\(Int(config.fps))"
        animationsFps = "\(Int(config.animationsFps))"
        renderingSlots = "\(Int(config.renderingSlots))"
        framesPerChunk = "\(Int(config.framesPerChunk))"
        sceneSize = .from(config.sceneSize)
        videoResolution = .from(config.videoResolution)
        cameraMode = config.cameraMode
        autoCharacterPlacement = config.autoCharacterPlacement
        autoTurnToAction = config.autoTurnToAction
        language = config.language
        renderingMode = config.renderingMode
        voiceEngine = config.voiceEngine
        cameraTransitionDuration = "\(config.cameraTransitionDuration)"
        yMultiplierVerticalMid = "\(Int(config.yMultiplierVerticalMid * 100))"
        assetsFolder = validatedFolder(config.assetsFolder)
        dubsFolder = validatedFolder(config.dubsFolder)
        videosFolder = validatedFolder(config.videosFolder)     
        cameraInsets = string(from: config.cameraInsets)
        bindAutoSave()
    }
    
    private func bindAutoSave() {
        objectWillChange
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                Task { @MainActor in
                    self.save()
                }
            }
            .store(in: &disposables)
    }
    
    @MainActor
    func delete() {
        storage.delete(config: config)
        tab?.navigateBack()
    }
    
    @MainActor
    func save() {        
        if let assetsFolder { config.assetsFolder = assetsFolder }
        if let dubsFolder { config.dubsFolder = dubsFolder }
        if let videosFolder { config.videosFolder = videosFolder }
        if let fps = TimeInterval(fps) { config.fps = fps }
        if let animationsFps = TimeInterval(animationsFps) { config.animationsFps = animationsFps }
        if let renderingSlots = Int(renderingSlots) { config.renderingSlots = renderingSlots }
        if let value = Float(yMultiplierVerticalMid) { config.yMultiplierVerticalMid = value/100 }
        if let value = Int(cameraTransitionDuration) { config.cameraTransitionDuration = value }
        if let value = Int(framesPerChunk) { config.framesPerChunk = value }
        if let value = edgeInsets(from: cameraInsets) { config.cameraInsets = value }
        
        config.name = name
        config.voiceEngine = voiceEngine
        config.renderingMode = renderingMode
        config.sceneSize = sceneSize.size
        config.videoResolution = videoResolution.size
        config.cameraMode = cameraMode
        config.autoCharacterPlacement = autoCharacterPlacement
        config.autoTurnToAction = autoTurnToAction
        config.language = language
        
        storage.save(config: config)
    }
    
    private func validatedFolder(_ url: URL) -> URL? {
        url.isTemporary ? nil : url
    }
    
    private func validatedFile(_ url: URL, defaultName: String) -> URL? {
        guard !url.isTemporary else { return nil }
        return if url.isExistingFolder() {
            url.appendingPathComponent(defaultName, conformingTo: .text)
        } else {
            url
        }
    }
    
    private func string(from insets: NSEdgeInsets) -> String {
        "\(Int(insets.top)), \(Int(insets.left)), \(Int(insets.bottom)), \(Int(insets.right))"
    }
    
    private func edgeInsets(from string: String) -> NSEdgeInsets? {
        let items = string
            .components(separatedBy: ",")
            .map { $0.replacingOccurrences(of: ",", with: "") }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .compactMap { Float($0) }
            .compactMap { CGFloat($0) }
        guard items.count == 4 else { return nil }
        return NSEdgeInsets(top: items[0], left: items[1], bottom: items[2], right: items[3])
    }
}

extension VideoResolution: FormPickerOption {}
extension SceneSize: FormPickerOption {}
extension SceneRenderingMode: FormPickerOption {}
