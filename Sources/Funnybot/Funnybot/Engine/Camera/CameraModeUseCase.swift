//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation
import Funnyscript

enum CameraMode: String, Codable, CaseIterable {
    case manual
    case contextAware
    case largeContextAware
    case singleFocusLargeViewPort
    case closeUps
}

extension CameraMode: CustomStringConvertible {
    var description: String {
        switch self {
        case .manual: "Manual"
        case .contextAware: "Auto - Context Aware"
        case .largeContextAware: "Auto - Large Context Aware"
        case .singleFocusLargeViewPort: "Auto - Single Focus Large Viewport"
        case .closeUps: "Auto - Close-ups"
        }
    }
}

extension CameraMode: FormPickerOption {
    // ...
}
