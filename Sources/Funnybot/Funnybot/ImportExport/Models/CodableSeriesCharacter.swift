//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation

struct CodableSeriesCharacter: Codable {
    let name: String
    let path: String
    let about: String
    let voice: String
    let quickVoice: String
    let usesMouthOverlay: Bool
    let usesEyesOverlay: Bool
    let eyesModifier: String?
    let customVoiceModel: String
    let codableMouthPositions: [String: CodableRect]
    let codableEyesPositions: [String: CodableRect]
    let isMainCast: Bool
    let afterTalkScript: String
    let size: Int

    init(from model: SeriesCharacter?) throws {
        guard let model else {
            throw ImportExportError.uncodable(model: "SeriesCharacter")
        }
        name = model.name
        path = model.path
        about = model.about
        voice = model.voice
        quickVoice = model.quickVoice ?? ""
        codableMouthPositions = model.codableMouthPositions
        codableEyesPositions = model.codableEyesPositions
        isMainCast = model.isMainCast
        afterTalkScript = model.afterTalkScript
        usesMouthOverlay = model.usesMouthOverlay
        usesEyesOverlay = model.usesEyesOverlay
        eyesModifier = model.eyesModifier
        customVoiceModel = model.customVoiceModel
        size = model.size
    }

    func asModel() -> SeriesCharacter {
        let model = SeriesCharacter()
        model.name = name
        model.path = path
        model.about = about
        model.voice = voice
        model.quickVoice = quickVoice
        model.afterTalkScript = afterTalkScript
        model.codableMouthPositions = codableMouthPositions
        model.codableEyesPositions = codableEyesPositions
        model.usesMouthOverlay = usesMouthOverlay
        model.usesEyesOverlay = usesEyesOverlay
        model.eyesModifier = eyesModifier
        model.isMainCast = isMainCast
        model.customVoiceModel = customVoiceModel
        model.size = size
        return model
    }
}
