//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation

public enum Direction: Equatable, CustomStringConvertible {
    case left
    case front
    case right
    case entity(id: String)
    
    public var description: String {
        switch self {
        case .left: "left"
        case .front: "front"
        case .right: "right"
        case .entity(let id): id
        }
    }
}
