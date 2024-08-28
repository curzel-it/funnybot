//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation

class ScenePositionParser {
    func scenePosition(from text: String) -> ScenePosition? {
        try? scenePosition(fromCleanText: text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    private func scenePosition(fromCleanText text: String) throws -> ScenePosition {
        let position = ScenePosition(
            side: side(from: text),
            verticalModifier: verticalModifier(from: text),
            horizontalModifier: horizontalModifier(from: text)
        )
        try validate(position, for: text)
        return position
    }
    
    private func validate(_ position: ScenePosition, for text: String) throws {
        let name = position.name.lowercased()
        guard name != text else { return }
        throw ScenePositionParserError.validationFailed(original: text, parsed: name)
    }
    
    private func side(from text: String) -> ScenePosition.Side {
        ScenePosition.Side.allCases.first {
            text.contains($0.rawValue)
        } ?? ScenePosition.Side.none
    }
    
    private func horizontalModifier(from text: String) -> ScenePosition.HorizontalModifier {
        ScenePosition.HorizontalModifier.allCases.first {
            text.contains($0.rawValue)
        } ?? .center
    }
    
    private func verticalModifier(from text: String) -> ScenePosition.VerticalModifier {
        ScenePosition.VerticalModifier.allCases.first {
            text.contains($0.rawValue)
        } ?? .mid
    }
}

enum ScenePositionParserError: Error {
    case validationFailed(original: String, parsed: String)
}
