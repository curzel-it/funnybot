//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation
import Schwifty
import SwiftData
import Yage

class EyesOverlayUser: BodyPartOverlayUser {
    override func buildOverlay(in world: World) -> Entity {
        let subjectId = subject?.id ?? "unknown"
        let species = Species(id: "eyes")
        return Entity(id: "\(subjectId)-eyes", species: species, in: world)
    }
    
    override func overlayReferenceFrame(for animation: String) -> CGRect? {
        character?.eyesPositions[animation]
    }
    
    override func nextAnimation() -> String {
        guard let subject else { return "" }
        return [
            subject.isLateral ? "lateral" : "front",
            subject.species.eyesModifier,
            subject.isAlive ? nil : "dead"
        ]
            .compactMap { $0 }
            .joined(separator: "_")
    }
}
