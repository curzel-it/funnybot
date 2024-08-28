//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation

public struct Species: Hashable, Identifiable, Equatable {
    public let id: String
    public let animations: [EntityAnimation]
    public let nickname: String
    public let size: CGFloat
    public let speed: CGFloat = 32
    public let hasTalkingAssets: Bool
    public let zIndex: CGFloat
    public let eyesModifier: String?
    
    let capabilities: [String]
    
    public init(
        id: String,
        nickname: String? = nil,
        size: CGFloat = 50,
        zIndex: CGFloat = 0,
        hasTalkingAssets: Bool = true,
        eyesModifier: String? = nil,
        additionalCapabilities: [String] = []
    ) {
        self.id = id
        self.size = size
        self.zIndex = zIndex
        self.nickname = nickname?.lowercased().replacingOccurrences(of: " ", with: "") ?? id
        self.hasTalkingAssets = hasTalkingAssets
        self.animations = []
        self.eyesModifier = eyesModifier
        self.capabilities = [
            "ActionExecutor",
            "AnimatedSprite",
            "AnimationsProvider",
            "FlipHorizontallyWhenGoingLeft",
            "LinearMovement",
            "Rotating",
            "SpritesProvider"
        ] + additionalCapabilities
    }
    
    public func animation(id: String) -> EntityAnimation {
        animations.first { $0.id == id } ?? EntityAnimation(id: id)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Species, rhs: Species) -> Bool {
        lhs.id == rhs.id
    }
}
