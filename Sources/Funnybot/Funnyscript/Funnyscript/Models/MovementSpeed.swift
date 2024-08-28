//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation

public enum MovementSpeed: String {
    case slug
    case crawl
    case walk
    case fly
    case run
    case drive
    case speed
    
    public var speedMultiplier: CGFloat {
        switch self {
        case .slug: 0.2
        case .crawl: 0.5
        case .walk: 1
        case .fly: 1.2
        case .run: 1.5
        case .drive: 2.5
        case .speed: 5
        }
    }
}
