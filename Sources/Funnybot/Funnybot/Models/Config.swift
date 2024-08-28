//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import AskGpt
import Foundation
import Funnyscript
import SwiftData
import Combine
import Foundation
import Schwifty

@Model
final class Config: IdentifiableRecord {
    var id: UUID = UUID()
    var name: String = "Default"
    var language: String = "English/US"
    var renderingSlots: Int = 3
    var framesPerChunk: Int = 100
    var fps: TimeInterval = 30
    var animationsFps: TimeInterval = 10
    var autoCharacterPlacement: Bool = true
    var autoTurnToAction: Bool = true
    var yMultiplierVerticalMid: Float = 0
    var cameraTransitionDuration: Int = 15
    
    var assetsFolder: URL = FileManager.default
        .temporaryDirectory
        .appendingPathComponent("assets", conformingTo: .folder)
    
    var dubsFolder: URL = FileManager.default
        .temporaryDirectory
        .appendingPathComponent("dubs", conformingTo: .folder)
    
    var videosFolder: URL = FileManager.default
        .temporaryDirectory
        .appendingPathComponent("videos", conformingTo: .folder)
    
    var frameTime: TimeInterval {
        1 / fps
    }
    
    var baseScale: CGFloat {
        videoResolution.height / sceneSize.height
    }
    
    private var codableVoiceEngine: String?
    private var codableRenderingMode: String
    private var codableSceneSize: CodableSize
    private var codableVideoResolution: CodableSize
    private var codableLastWindowFrame: CodableRect?
    private var codableCameraInsets: CodableEdgeInsets?
    private var codableCameraMode: String = CameraMode.manual.rawValue
    
    var voiceEngine: VoiceEngine {
        get { VoiceEngine(rawValue: codableVoiceEngine ?? "") ?? .onDevice }
        set { codableVoiceEngine = newValue.rawValue }
    }
    
    var cameraMode: CameraMode {
        get { CameraMode(rawValue: codableCameraMode) ?? .manual }
        set { codableCameraMode = newValue.rawValue }
    }
    
    var renderingMode: SceneRenderingMode {
        get { SceneRenderingMode(rawValue: codableRenderingMode) ?? .regular }
        set { codableRenderingMode = newValue.rawValue }
    }
    
    var sceneSize: CGSize {
        get { codableSceneSize.size() }
        set { codableSceneSize = CodableSize(from: newValue) }
    }
    
    var videoResolution: CGSize {
        get { codableVideoResolution.size() }
        set { codableVideoResolution = CodableSize(from: newValue) }
    }
    
    var cameraInsets: NSEdgeInsets {
        get { codableCameraInsets?.edgeInsets() ?? .init() }
        set { codableCameraInsets = CodableEdgeInsets(from: newValue) }
    }
    
    init() {
        id = UUID()
        codableVoiceEngine = ""
        animationsFps = 10
        language = "English/US"
        codableRenderingMode = SceneRenderingMode.regular.rawValue
        codableSceneSize = CodableSize(from: SceneSize.standard.size)
        codableVideoResolution = CodableSize(from: VideoResolution.fullHd.size)
        yMultiplierVerticalMid = 0.06
        name = "Default"
        cameraTransitionDuration = 15
        codableCameraInsets = CodableEdgeInsets(from: .init())
        codableCameraMode = CameraMode.manual.rawValue
    }
}

extension Config: CustomStringConvertible {
    var description: String {
        [
            name,
            renderingMode.description,
            VideoResolution.from(videoResolution).name,
            SceneSize.from(sceneSize).name
        ].joined(separator: " | ")
    }
}
