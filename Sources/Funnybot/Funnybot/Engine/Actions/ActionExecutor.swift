import AVFoundation
import Foundation
import Funnyscript
import Schwifty
import Yage

extension Entity {
    func apply(_ action: Action) async throws {
        let executor = try capability(for: ActionExecutor.self).unwrap()
        try await executor.apply(action)
    }
}

class ActionExecutor: Capability {
    @Inject private var dubsStorage: DubsStorage
    @Inject private var assets: AssetsProvider
    
    func apply(_ action: Action) async throws {
        Logger.debug(tag, action.description)
        
        switch action {
        case .animation(let id, let loops): playAnimation(id: id, loops: loops)
        case .coordinateSet(let axis, let value): setPosition(along: axis, to: value)
        case .custom(let foo): foo()
        case .emotion(let emotion): set(emotion: emotion)
        case .movement(let destination, let movementSpeed): move(to: destination, at: movementSpeed)
        case .none: return
        case .offset(let axis, let value): offset(along: axis, by: value)
        case .opacity(let value, let smoothly): transitionOpacity(to: value, smoothly: smoothly)
        case .placement(let destination): placement(to: destination)
        case .scale(let value): scale(factor: value)
        case .talking(let line, _): try await talk(text: line)
        case .turn(let target): turn(to: target)
        case .shuffle, .background, .camera, .clearStage, .pause: return
        }
    }
    
    private func set(emotion: Emotion) {
        subject?.emotion = emotion
    }
    
    private func scale(factor: CGFloat) {
        guard let subject else { return }
        subject.set(size: subject.size.scaled(factor))
    }
    
    private func offset(along axis: Axis, by offset: CGFloat) {
        guard let subject else { return }
        let currentValue = switch axis {
        case .x: subject.frame.minX
        case .y: subject.frame.minY
        case .z: subject.zIndex
        }
        setPosition(along: axis, to: currentValue + offset)
    }
    
    private func setPosition(along axis: Axis, to value: CGFloat) {
        guard let subject else { return }
        switch axis {
        case .x: subject.set(position: CGPoint(x: value, y: subject.frame.minY))
        case .y: subject.set(position: CGPoint(x: subject.frame.minX, y: value))
        case .z: subject.zIndex = value
        }
    }
    
    private func flip(vertically: Bool, horizontally: Bool) {
        subject?.rotation?.isFlippedVertically = vertically
        subject?.rotation?.isFlippedHorizontally = horizontally
    }
    
    private func transitionOpacity(to value: CGFloat, smoothly: Bool) {
        guard let subject else { return }
        guard let opacity = subject.capability(for: OpacityTransitioner.self) else { return }
        opacity.transition(to: value, smoothly: smoothly)
    }
    
    private func playAnimation(id: String, loops: Int?) {
        guard let subject else { return }
        guard animationExists(id: id) else { return }
        subject.capability(for: Seeker.self)?.kill()
        let animation = subject.species.animation(id: id)
        subject.set(state: .action(action: animation, loops: loops))
    }
    
    private func move(to destination: Position, at movementSpeed: MovementSpeed) {
        guard let subject else { return }
        let position = subject.position(for: destination)
        subject.set(speedMultiplier: movementSpeed.speedMultiplier)
        subject.walk(to: position)
    }
    
    private func turn(to target: Direction) {
        guard let subject else { return }
        subject.set(direction: direction(for: target))
        
        if subject.state.isAction {
            subject.set(state: .action(action: .idling, loops: nil))
        }
    }
    
    private func placement(to destination: Position) {
        subject?.place(at: destination)
    }
    
    private func talk(text: String) async throws {
        guard let subject else { return }
        let url = dubsStorage.dub(speaker: subject.species.nickname, line: text)
        subject.talk(text: text, url: url)
    }
    
    private func direction(for target: Direction) -> CGVector {
        guard let subject else { return .zero }
        switch target {
        case .front: return .front
        case .left: return .left
        case .right: return .right
        case .entity(let id):
            if let target = subject.neighboor(matching: id)?.frame.center {
                if target.x < subject.frame.center.x { return .left }
                if target.x > subject.frame.center.x { return .right }
            }
            return .zero
        }
    }
    
    private func animationExists(id: String) -> Bool {
        !assets.frames(for: subject?.species.id ?? "", animation: id).isEmpty
    }
    
    private func entity(id: String) -> Entity? {
        subject?.world?.children.first { $0.species.id == id }
    }
}
