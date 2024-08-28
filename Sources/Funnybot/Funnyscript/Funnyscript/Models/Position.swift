//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation
import Schwifty

public enum Position: Equatable, CustomStringConvertible {
    case entity(id: String)
    case scenePosition(position: ScenePosition)
    
    public var description: String {
        return switch self {
        case .entity(let id): id
        case .scenePosition(let position): position.name
        }
    }
    
    public var isInsideScene: Bool {
        switch self {
        case .entity: true
        case .scenePosition(let position): position.isInsideScene
        }
    }
}
