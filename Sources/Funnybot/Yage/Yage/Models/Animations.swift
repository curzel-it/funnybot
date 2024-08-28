//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Schwifty
import SwiftUI

public struct EntityAnimation: Codable {
    public let id: String
    public let facingDirection: CGVector?
    public let requiredLoops: Int?
    public let size: CGSize?
    public let position: Position

    public init(
        id: String,
        size: CGSize? = nil,
        position: Position = .fromEntityBottomLeft,
        facingDirection: CGVector? = nil,
        requiredLoops: Int? = nil
    ) {
        self.id = id
        self.size = size
        self.position = position
        self.facingDirection = facingDirection
        self.requiredLoops = requiredLoops
    }

    public func frame(for entity: Entity) -> CGRect? {
        if size == nil && position == .fromEntityBottomLeft { return nil }
        let newSize = size(for: entity.frame.size)
        let newPosition = position(
            originalFrame: entity.frame,
            newSize: newSize,
            in: entity.worldBounds
        )        
        return CGRect(origin: newPosition, size: newSize)
    }

    private func size(for originalSize: CGSize) -> CGSize {
        size ?? originalSize
    }

    private func position(
        originalFrame entityFrame: CGRect,
        newSize: CGSize,
        in worldBounds: CGRect
    ) -> CGPoint {
        switch position {
        case .fromEntityBottomLeft:
            return entityFrame.origin
                .offset(y: entityFrame.size.height - newSize.height)

        case .entityTopLeft:
            return entityFrame.origin

        case .worldTopLeft:
            return worldBounds.topLeft

        case .worldTopRight:
            return worldBounds.topRight.offset(x: -entityFrame.width)

        case .worldBottomRight:
            return worldBounds.bottomRight.offset(by: entityFrame.size.oppositeSign())

        case .worldBottomLeft:
            return worldBounds.bottomLeft.offset(y: -entityFrame.height)
        }
    }
}

extension EntityAnimation: Equatable {
    public static func ==(lhs: EntityAnimation, rhs: EntityAnimation) -> Bool {
        lhs.id == rhs.id
    }
}

extension EntityAnimation: CustomStringConvertible {
    public var description: String { id }
}

extension EntityAnimation {
    public enum Position: String, Codable {
        case fromEntityBottomLeft
        case entityTopLeft
        case worldTopLeft
        case worldBottomLeft
        case worldTopRight
        case worldBottomRight
    }
}

extension EntityAnimation {
    public func with(loops: Int) -> EntityAnimation {
        EntityAnimation(
            id: id,
            size: size,
            position: position,
            facingDirection: facingDirection,
            requiredLoops: loops
        )
    }
}

public extension EntityAnimation {
    static let idling = EntityAnimation(id: "idling")
    static let none = EntityAnimation(id: "none")
    
    var isIdling: Bool {
        let idlingIds = ["idle", "lateral", "front", "idling"]
        return idlingIds.contains(id)
    }
}
