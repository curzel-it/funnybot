//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Combine
import Schwifty
import SwiftUI

public class Entity: Identifiable {
    static var pixelPerfectMovement = false
    
    public weak var parent: Entity?
    
    public let species: Species
    public let id: String
    var capabilities: [Capability] = []
    let creationDate = Date()
    public private(set) var direction: CGVector = .zero
    public private(set) var frame: CGRect = CGRect(square: 1)
    public var isEphemeral: Bool = false
    public var alpha: CGFloat = 1
    public private(set) var isAlive: Bool = true
    public var isStatic: Bool = false
    public private(set) var speed: CGFloat = 0
    public private(set) var sprite: String?
    public private(set) var lastUpdateTime: TimeInterval = 0
    public private(set) var state: EntityState = .action(action: .idling, loops: nil)
    public private(set) weak var world: World?
    public var worldBounds: CGRect { world?.bounds ?? .zero }
    public var zIndex: CGFloat = 1
        
    public var isRenderable: Bool {
        sprite != nil && isAlive && !isEphemeral
    }
    
    var disposables = Set<AnyCancellable>()
    
    public init(id: String? = nil, species: Species, in world: World) {
        self.id = id ?? Entity.nextId(for: species)
        self.species = species
        self.world = world
        resetFrame()
        resetSpeed()
        resetZIndex()
        installCapabilities()
    }
    
    public func update(after timeSinceLastUpdate: TimeInterval) async {
        if isAlive {
            await capabilities.asyncForEach {
                await $0.update(after: timeSinceLastUpdate)
            }
        }
        lastUpdateTime += timeSinceLastUpdate
    }
    
    // MARK: - World
    
    func worldBoundsChanged() {
        // ...
    }
    
    // MARK: - Geometry
    
    public var size: CGSize {
        frame.size
    }
    
    public func set(frame newFrame: CGRect) {
        if Config.shared.pixelPerfectMovement {
            frame = CGRect(
                x: floor(newFrame.minX),
                y: floor(newFrame.minY),
                width: floor(newFrame.width),
                height: floor(newFrame.height)
            )
        } else {
            frame = newFrame
        }        
    }
    
    public func set(position: CGPoint) {
        set(frame: CGRect(origin: position, size: frame.size))
    }
    
    public func set(size: CGSize) {
        set(frame: CGRect(origin: frame.origin, size: size))
    }
    
    public func set(direction: CGVector) {
        self.direction = direction
    }
    
    public var isLateral: Bool {
        direction.isLateral || (sprite ?? "").contains("lateral") || state == .move
    }
    
    // MARK: - Capabilities
    
    private func installCapabilities() {
        species.capabilities.forEach {
            if let capability = Capabilities.discovery.capability(for: $0) {
                install(capability)
            }
        }
    }
    
    public func capability<T: Capability>(for someType: T.Type) -> T? {
        capabilities.first { $0 as? T != nil } as? T
    }
    
    public func hasCapability<T: Capability>(_ someType: T.Type) -> Bool {
        capability(for: someType) != nil
    }
    
    public func uninstall<T: Capability>(_ someType: T.Type) {
        capabilities
            .first { $0 is T }?
            .kill(autoremove: true)
    }

    // MARK: - State
    
    public func set(sprite: String?) {
        self.sprite = sprite
    }

    public func set(state newState: EntityState) {
        state = newState
    }
    
    public func resetRotation() {
        rotation?.reset()
    }
    
    public func resetFrame() {
        set(frame: CGRect(square: species.size))
    }

    public func resetSpeed() {
        speed = species.speed
    }

    public func resetZIndex() {
        zIndex = species.zIndex
    }
    
    public func set(speedMultiplier: CGFloat) {
        speed = species.speed * speedMultiplier
    }
    
    // MARK: - Lifecycle

    public func kill() {
        isAlive = false
        uninstallAllCapabilities()
        set(sprite: nil)
    }
    
    public func uninstallAllCapabilities() {
        capabilities.forEach { $0.kill(autoremove: false) }
        capabilities = []
    }
}

// MARK: - Debug

extension Entity: CustomStringConvertible {
    public var description: String {
        id
    }
}

// MARK: - Equatable

extension Entity: Equatable {
    public static func == (lhs: Entity, rhs: Entity) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Next Id

private extension Entity {
    static func nextId(for species: Species) -> String {
        nextNumber += 1
        return "\(species.id)-\(nextNumber)"
    }

    private static var nextNumber = 0
}
