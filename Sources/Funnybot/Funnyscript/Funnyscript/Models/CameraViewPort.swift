//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation
import SwiftUI

public enum CameraViewport: CustomStringConvertible {
    case original
    case rect(frame: CGRect)
    case entities(names: [String])
    
    public var description: String {
        return switch self {
        case .entities(let ids): "on \(ids.joined(separator: ", "))"
        case .rect(let frame): frame.viewportString
        case .original: "original"
        }
    }
    
    static func from(_ string: String) -> CameraViewport {
        if let viewport = viewport(from: string) {
            return .rect(frame: viewport)
        } else {
            let ids = string
                .components(separatedBy: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            return .entities(names: ids)
        }
    }
    
    private static func viewport(from viewportString: String) -> CGRect? {
        let tokens = viewportString
            .components(separatedBy: "x")
            .flatMap { $0.components(separatedBy: "+") }
            .compactMap { Float($0) }
            .map { CGFloat($0) }
        
        guard tokens.count == 4 else { return nil }
        
        return CGRect(
            x: tokens[2],
            y: tokens[3],
            width: tokens[0],
            height: tokens[1]
        )
    }
}

public extension CGRect {
    var viewportString: String {
        "\(Int(width))x\(Int(height))+\(Int(origin.x))+\(Int(origin.y))"
    }
}
