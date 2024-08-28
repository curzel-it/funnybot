//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import AskGpt
import Foundation

struct CodableConfig: Codable {
    let name: String
    let language: String
    let renderingSlots: Int
    let framesPerChunk: Int
    let fps: TimeInterval
    let animationsFps: TimeInterval
    let renderingMode: SceneRenderingMode
    let sceneSize: CGSize
    let videoResolution: CGSize
    let cameraInsets: CodableEdgeInsets
    let cameraMode: CameraMode
    let autoCharacterPlacement: Bool
    let autoTurnToAction: Bool
    let assetsFolder: URL
    let dubsFolder: URL
    let videosFolder: URL
    let yMultiplierVerticalMid: Float
    let cameraTransitionDuration: Int
    let voiceEngine: VoiceEngine

    init(from model: Config?) throws {
        guard let model else {
            throw ImportExportError.uncodable(model: "Config")
        }
        voiceEngine = model.voiceEngine
        name = model.name
        language = model.language
        renderingSlots = model.renderingSlots
        framesPerChunk = model.framesPerChunk
        fps = model.fps
        animationsFps = model.animationsFps
        renderingMode = model.renderingMode
        cameraInsets = CodableEdgeInsets(from: model.cameraInsets)
        cameraMode = model.cameraMode
        autoCharacterPlacement = model.autoCharacterPlacement
        autoTurnToAction = model.autoTurnToAction
        assetsFolder = model.assetsFolder
        dubsFolder = model.dubsFolder
        videosFolder = model.videosFolder
        videoResolution = model.videoResolution
        sceneSize = model.sceneSize
        yMultiplierVerticalMid = model.yMultiplierVerticalMid
        cameraTransitionDuration = model.cameraTransitionDuration
    }

    func asModel() -> Config {
        let model = Config()
        model.name = name
        model.voiceEngine = voiceEngine
        model.language = language
        model.renderingSlots = renderingSlots
        model.framesPerChunk = framesPerChunk
        model.fps = fps
        model.animationsFps = animationsFps
        model.renderingMode = renderingMode
        model.cameraInsets = cameraInsets.edgeInsets()
        model.cameraMode = cameraMode
        model.autoCharacterPlacement = autoCharacterPlacement
        model.autoTurnToAction = autoTurnToAction
        model.assetsFolder = assetsFolder
        model.dubsFolder = dubsFolder
        model.videosFolder = videosFolder
        model.videoResolution = videoResolution
        model.sceneSize = sceneSize
        model.yMultiplierVerticalMid = yMultiplierVerticalMid
        model.cameraTransitionDuration = cameraTransitionDuration
        return model
    }
}
