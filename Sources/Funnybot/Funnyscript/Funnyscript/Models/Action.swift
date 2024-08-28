//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation

public enum Action {
    case animation(id: String, loops: Int?)
    case background(name: String)
    case camera(view: CameraViewport, smoothly: Bool)
    case clearStage
    case coordinateSet(axis: Axis, value: CGFloat)
    case custom(foo: () -> Void)
    case emotion(emotion: Emotion)
    case movement(destination: Position, speed: MovementSpeed)
    case none
    case offset(axis: Axis, value: CGFloat)
    case opacity(value: CGFloat, smoothly: Bool)
    case pause(duration: TimeInterval)
    case placement(destination: Position)
    case scale(value: CGFloat)
    case shuffle(hard: Bool, count: Int?)
    case talking(line: String, info: String)
    case turn(target: Direction)
}

extension Action: CustomStringConvertible {
    public var description: String {
        switch self {
        case .animation(let id, let loops): "play \(id) \(formatted(animationLoops: loops))"
        case .background(let name): "background \(name)"
        case .camera(let view, let smoothly): formatted(cameraView: view, smoothly: smoothly)
        case .clearStage: "clear"
        case .coordinateSet(let axis, let value): "set \(formatted(axis: axis, value: value))"
        case .custom(_): "custom function"
        case .emotion(let emotion): "play \(emotion.rawValue)"
        case .movement(let destination, let movementSpeed): "\(movementSpeed.rawValue) to \(destination)"
        case .none: "none"
        case .offset(let axis, let value): "offset \(formatted(axis: axis, value: value))"
        case .opacity(let value, let smoothly): formatted(opacity: value, transition: smoothly)
        case .pause(let time): "pause \(formatted(duration: time))"
        case .placement(let destination): "at \(destination)"
        case .scale(let value): "scale \(value)"
        case .shuffle(let hard, let count): formattedShuffle(hard: hard, count: count)
        case .talking(let line, _): "\"\(line.replacingOccurrences(of: "\"", with: "'"))\""
        case .turn(let direction): "turn \(direction)"
        }
    }
    
    private func formattedShuffle(hard: Bool, count: Int?) -> String {
        [
            "shuffle",
            hard ? "hard" : "",
            count != nil ? "\(count ?? 0)" : ""
        ]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
    
    private func formatted(cameraView: CameraViewport, smoothly: Bool) -> String {
        "\(smoothly ? "transition " : "")view \(cameraView)"
    }
    
    private func formatted(axis: Axis, value: CGFloat) -> String {
        "\(axis.rawValue) \(Int(value))"
    }
    
    private func formatted(flipVertically vly: Bool, horizontally hly: Bool) -> String {
        if vly && hly { return "flip vertically horizontally" }
        if vly { return "flip vertically" }
        if hly { return "flip horizontally" }
        return "flip restore"
    }
    
    private func formatted(opacity: CGFloat, transition smoothly: Bool) -> String {
        if smoothly {
            let name = switch opacity {
            case 0: "out"
            case 1: "in"
            default: "\(opacity)"
            }
            return "fade \(name)"
        } else {
            return "opacity \(opacity)"
        }
    }
    
    private func formatted(animationLoops loops: Int?) -> String {
        if let loops { return "\(loops)" }
        return "loop"
    }
    
    private func formatted(duration: TimeInterval) -> String {
        let formatted = String(format: "%0.2f", duration)
        var trimmed = formatted.trimmingCharacters(in: CharacterSet(charactersIn: "0"))
        if trimmed.last == "." { trimmed.removeLast() }
        return trimmed
    }
}

extension Action: Equatable {
    public static func == (lhs: Action, rhs: Action) -> Bool {
        lhs.description == rhs.description
    }
}

public extension Action {
    var isPlacement: Bool {
        switch self {
        case .placement: true
        case .coordinateSet(let axis, _): axis != .z
        default: false
        }
    }
    
    var isMovement: Bool {
        switch self {
        case .movement: true
        default: false
        }
    }
    
    var isClearStage: Bool {
        switch self {
        case .clearStage: true
        default: false
        }
    }
    
    var isAnimation: Bool {
        switch self {
        case .animation: true
        default: false
        }
    }
}
