//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation

enum SceneRenderingMode: String, CustomStringConvertible, Codable, CaseIterable {
    case regular
    case pixelArt
    
    var description: String {
        switch self {
        case .regular: "Regular"
        case .pixelArt: "Optimized for Pixel Art"
        }
    }
}
