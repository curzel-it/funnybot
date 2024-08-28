//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation

public struct ScenePosition: Equatable {
    public let side: Side
    public let verticalModifier: VerticalModifier
    public let horizontalModifier: HorizontalModifier
    
    public var name: String {
        [
            horizontalModifier.rawValue,
            side.rawValue.capitalized,
            verticalModifier.rawValue.capitalized
        ].joined(separator: "")
    }
}

extension ScenePosition {
    public enum Side: String, CaseIterable {
        case right
        case none = ""
        case left
    }
    
    public enum HorizontalModifier: String, CaseIterable {
        case outside
        case far
        case mid
        case center
    }
    
    public enum VerticalModifier: String, CaseIterable {
        case below
        case bottom
        case mid = ""
        case high
        case top
        case over
    }
}

public extension ScenePosition {
    var isInsideScene: Bool {
        // TODO: Second part needed?
        horizontalModifier != .outside && verticalModifier != .over && verticalModifier != .below
    }
    
    var isOnRight: Bool {
        side == .right
    }
    
    var isHorizontalCenter: Bool {
        side == .none
    }
    
    var isOnRightOrCenter: Bool {
        isOnRight || isHorizontalCenter
    }
}

public extension ScenePosition {
    static let center = ScenePosition(side: .none, verticalModifier: .mid, horizontalModifier: .center)
    static let centerRight = ScenePosition(side: .right, verticalModifier: .mid, horizontalModifier: .center)
    static let centerLeft = ScenePosition(side: .left, verticalModifier: .mid, horizontalModifier: .center)
    static let midRight = ScenePosition(side: .right, verticalModifier: .mid, horizontalModifier: .mid)
    static let midLeft = ScenePosition(side: .left, verticalModifier: .mid, horizontalModifier: .mid)
    static let farRight = ScenePosition(side: .right, verticalModifier: .mid, horizontalModifier: .far)
    static let farLeft = ScenePosition(side: .left, verticalModifier: .mid, horizontalModifier: .far)
    static let outsideRight = ScenePosition(side: .right, verticalModifier: .mid, horizontalModifier: .outside)
    static let outsideLeft = ScenePosition(side: .left, verticalModifier: .mid, horizontalModifier: .outside)
    static let outsideRightBelow = ScenePosition(side: .right, verticalModifier: .below, horizontalModifier: .outside)
    
    static let basicPositions: [ScenePosition] = [
        center, centerRight, centerLeft,
        midRight, midLeft,
        farRight, farLeft
    ]
}
