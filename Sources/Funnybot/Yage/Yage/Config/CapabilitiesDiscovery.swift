//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation

public class Capabilities {
    public static let discovery = CapabilitiesDiscoveryService()
}

public class CapabilitiesDiscoveryService {
    private var map: [String: () -> Capability] = [
        "animatedsprite": { AnimatedSprite() },
        "animationsprovider": { AnimationsProvider() },
        "fliphorizontallywhengoingleft": { FlipHorizontallyWhenGoingLeft() },
        "linearmovement": { LinearMovement() },
        "opacitytransitioner": { OpacityTransitioner() },
        "rotating": { Rotating() },
        "seeker": { Seeker() },
        "spritesprovider": { SpritesProvider() }
    ]
    
    public func capability(for id: String) -> Capability? {
        map[id.lowercased()]?()
    }
    
    public func register(_ key: String, builder: @escaping () -> Capability) {
        map[key.lowercased()] = builder
    }
}
