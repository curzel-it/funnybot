//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation
import SwiftData
import Yage

@Model
final class SeriesCharacter: IdentifiableRecord {
    let id = UUID()
    var name: String = ""
    var path: String = ""
    var about: String = ""
    var voice: String = ""
    var quickVoice: String? = ""
    var eyesModifier: String? = nil
    var afterTalkScript: String = ""
    var usesMouthOverlay: Bool = false
    var usesEyesOverlay: Bool = false
    var isMainCast: Bool = false
    var size: Int = 50
    var customVoiceModel: String = ""
    var volume: Int = 100
    
    @Relationship(inverse: \Series.characters) var series: Series?
    
    var eyesPositions: [String: CGRect] {
        get {
            codableEyesPositions.reduce([:]) { partialResult, pair in
                var partialResult = partialResult
                partialResult[pair.key] = pair.value.rect()
                return partialResult
            }
        }
        set {
            codableEyesPositions = newValue.reduce([:]) { partialResult, pair in
                var partialResult = partialResult
                partialResult[pair.key] = CodableRect(from: pair.value)
                return partialResult
            }
        }
    }
    
    var mouthPositions: [String: CGRect] {
        get {
            codableMouthPositions.reduce([:]) { partialResult, pair in
                var partialResult = partialResult
                partialResult[pair.key] = pair.value.rect()
                return partialResult
            }
        }
        set {
            codableMouthPositions = newValue.reduce([:]) { partialResult, pair in
                var partialResult = partialResult
                partialResult[pair.key] = CodableRect(from: pair.value)
                return partialResult
            }
        }
    }
    
    var codableEyesPositions: [String: CodableRect] = [:]
    var codableMouthPositions: [String: CodableRect] = [:]
    
    init(series: Series, name: String, path: String, about: String) {
        self.name = name
        self.path = path
        self.about = about
        self.series = series
        self.isMainCast = false
        self.usesMouthOverlay = false
        self.usesEyesOverlay = false
        self.eyesModifier = nil
        self.customVoiceModel = ""
        self.codableMouthPositions = [:]
        self.codableEyesPositions = [:]
        self.afterTalkScript = ""
        self.quickVoice = ""
        self.volume = 100
    }
    
    init() {
        self.quickVoice = ""
        self.afterTalkScript = ""
        self.volume = 100
    }
    
    func species() -> Species {
        Species(
            id: path,
            nickname: name,
            size: CGFloat(size),
            hasTalkingAssets: !usesMouthOverlay,
            eyesModifier: eyesModifier,
            additionalCapabilities: additionalCapabilities()
        )
    }
    
    func matches(nameOrPath: String) -> Bool {
        let match = nameOrPath.lowercased()
        return path == match || name.lowercased() == match
    }
    
    private func additionalCapabilities() -> [String] {
        [
            "Emotional",
            "TalkingCharacter",
            usesMouthOverlay ? "MouthOverlayUser" : nil,
            usesEyesOverlay ? "EyesOverlayUser" : nil
        ].compactMap { $0 }
    }
}

extension SeriesCharacter: Comparable {
    static func < (lhs: SeriesCharacter, rhs: SeriesCharacter) -> Bool {
        if lhs.isMainCast != rhs.isMainCast {
            return lhs.isMainCast
        }
        return lhs.name < rhs.name
    }
}
