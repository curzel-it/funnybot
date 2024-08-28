//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation

public protocol Config {
    var autoCharacterPlacement: Bool { get }
    var autoTurnToAction: Bool { get }
    var useManualCamera: Bool { get }
    var useContextAwareAutoCamera: Bool { get }
    var useLargeContextAwareAutoCamera: Bool { get }
    var useCloseUpsAutoCamera: Bool { get }
    var frameTime: TimeInterval { get }
}

public enum CameraMode: String, Codable, CaseIterable {
    case manual
    case contextAware
    case closeUps
}
