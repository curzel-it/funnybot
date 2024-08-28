//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Schwifty
import SwiftUI

open class World: Identifiable {
    public let name: String
    public let id: UUID
    public var children: [Entity] = []
    
    public private(set) var bounds: CGRect = .zero
    public private(set) var lastUpdateTime: TimeInterval = 0

    public var renderableChildren: [Entity] {
        children.filter { $0.isRenderable }
    }
    
    public init(name: String, id: UUID, bounds rect: CGRect) {
        self.name = name
        self.id = id
        set(bounds: rect)
    }
    
    public func set(bounds newBounds: CGRect) {
        guard bounds != newBounds else { return }
        bounds = newBounds
        children.forEach { $0.worldBoundsChanged() }
    }
    
    open func update(after timeSinceLastUpdate: TimeInterval) async {
        lastUpdateTime += timeSinceLastUpdate
        await children
            .filter { !$0.isStatic }
            .asyncForEach { await $0.update(after: timeSinceLastUpdate) }
    }
    
    public func kill() {
        children.forEach { $0.kill() }
        children.removeAll()
    }
    
    public func child(id: String) -> Entity? {
        children.first { $0.id == id }
    }
    
    public func child(species id: String) -> Entity? {
        children.first { $0.species.id == id }
    }
    
    public func child(species: Species) -> Entity? {
        child(id: species.id)
    }
    
    func animate(id: String, action: String, position: CGPoint?) {
        let subject = children.first { $0.species.id == id }
        let animation = subject?.species.animations.first { $0.id == action }
        guard let subject, let animation else { return }
        
        if let position {
            subject.set(position: position)
        }
        subject.set(state: .action(action: animation, loops: nil))
    }
    
    open func schedule(at time: TimeInterval, for someIdentifier: String, _ foo: @escaping () -> Void) {
        fatalError("Not implemented here yet")
    }
}
