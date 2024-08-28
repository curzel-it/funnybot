//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation

enum SceneSize: String, CustomStringConvertible, CaseIterable {
    case standard
    case compact
    
    var description: String {
        "\(name) | \(heightString) | \(resolutionString)"
    }
    
    var name: String {
        switch self {
        case .standard: "Standard"
        case .compact: "Compact"
        }
    }
    
    var resolutionString: String {
        switch self {
        case .standard: "320 x 180"
        case .compact: "240 x 160"
        }
    }
    
    var heightString: String {
        switch self {
        case .standard: "16:9"
        case .compact: "3:2"
        }
    }
    
    var size: CGSize {
        switch self {
        case .standard: CGSize(width: 320, height: 180)
        case .compact: CGSize(width: 240, height: 160)
        }
    }
    
    static func from(_ size: CGSize) -> Self {
        switch size.height {
        case 180: .standard
        case 160: .compact
        default: .standard
        }
    }
}
