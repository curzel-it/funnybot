import Foundation

open class OverlayCapability: Capability {
    public private(set) weak var overlay: Entity?
    
    open override func install(on subject: Entity) {
        super.install(on: subject)
        guard let world = subject.world else { return }
        setupOverlay(for: subject, in: world)
    }
    
    public func setupOverlay(for subject: Entity, in world: World) {
        let overlay = buildOverlay(in: world)
        overlay.parent = subject
        self.overlay = overlay
        world.children.append(overlay)
    }
    
    override open func doUpdate(after time: TimeInterval) async {
        await super.doUpdate(after: time)
        guard let subject, let overlay else { return }
        overlay.zIndex = subject.zIndex
        overlay.alpha = subject.alpha
    }
    
    open func buildOverlay(in world: World) -> Entity {
        Entity(species: Species(id: "\(type(of: self))"), in: world)
    }
}
