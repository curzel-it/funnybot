//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Combine
import NotAGif
import Schwifty
import SwiftUI

public class AnimatedSprite: Capability {
    private(set) var animation: SpritesAnimator = .none
    private var lastFrameBeforeAnimations: CGRect = .zero
    private var lastDirection: CGVector = .zero
    private var lastState: EntityState = .action(action: .none, loops: nil)
    private var lastTalking: Bool = false
    private var fps: TimeInterval = Config.shared.fps

    public override func install(on subject: Entity) {
        super.install(on: subject)
        lastFrameBeforeAnimations = subject.frame
    }

    public override func doUpdate(after time: TimeInterval) async {
        updateSpriteIfStateChanged()
        loadNextFrame(after: time)
        storeFrameIfNeeded()
    }

    public override func kill(autoremove: Bool = true) {
        setSprite(nil)
        super.kill(autoremove: autoremove)
        animation = .none
    }
    
    public func load(spritesSequence: [String], name: String, state: EntityState, talking: Bool, loop: Bool) {
        lastTalking = talking
        lastState = state
        animation.clearHooks()
        animation = SpritesAnimator(
            baseName: name, frames: spritesSequence, fps: fps,
            onFirstFrameLoaded: { completedLoops in
                guard completedLoops == 0 else { return }
                self.handleAnimationStarted(setFrame: nil)
            },
            onLoopCompleted: { completedLoops in
                guard !loop else { return } 
                self.handleAnimationCompleted()
            }
        )
        if let frame = animation.currentFrame() {
            setSprite(frame)
        }
    }
    
    func reset() {
        lastFrameBeforeAnimations = .zero
        lastState = .action(action: .none, loops: nil)
        lastTalking = false
    }

    private func updateSpriteIfStateChanged() {
        guard let subject else { return }
        guard stateChanged(for: subject) else { return }
        lastDirection = subject.direction
        lastState = subject.state
        lastTalking = subject.isTalking
        updateSprite()
    }
    
    private func stateChanged(for subject: Entity) -> Bool {
        [
            subject.state != lastState,
            subject.isTalking != lastTalking,
            subject.direction != lastDirection
        ].contains(true)
    }

    private func loadNextFrame(after time: TimeInterval) {
        guard let next = animation.nextFrame(after: time) else { return }
        setSprite(next)
    }

    private func storeFrameIfNeeded() {
        guard let subject else { return }
        guard !subject.state.isAction else { return }
        lastFrameBeforeAnimations = subject.frame
    }

    private func updateSprite() {
        guard let path = subject?.spritesProvider?.sprite(state: lastState) else { return }
        guard path != animation.baseName else {
            Logger.debug(tag, "Same path, skipping")
            return
        }
        Logger.log(tag, "Loading", path)
        animation.clearHooks()
        animation = buildAnimator(animation: path, state: lastState)
        if let frame = animation.currentFrame() { setSprite(frame) }
    }

    private func buildAnimator(animation: String, state: EntityState) -> SpritesAnimator {
        guard let subject else { return .none }
        guard let frames = subject.spritesProvider?.frames(state: state) else {
            Logger.log(tag, "No sprites to load")
            return .none
        }
        if case .action(let anim, let requiredLoops) = state {
            let requiredFrame = anim.frame(for: subject)
            return SpritesAnimator(
                baseName: animation,
                frames: frames,
                fps: fps,
                onFirstFrameLoaded: { completedLoops in
                    guard completedLoops == 0 else { return }
                    self.handleAnimationStarted(setFrame: requiredFrame)
                },
                onLoopCompleted: { completedLoops in
                    guard requiredLoops == completedLoops else { return }
                    self.handleAnimationCompleted()
                }
            )
        } else {
            return SpritesAnimator(baseName: animation, frames: frames, fps: fps)
        }
    }

    func handleAnimationStarted(setFrame requiredFrame: CGRect?) {
        guard let requiredFrame else { return }
        subject?.set(frame: requiredFrame)
    }

    func handleAnimationCompleted() {
        Logger.log(tag, "Animation completed")
        subject?.set(frame: lastFrameBeforeAnimations)
        subject?.set(state: .action(action: .idling, loops: nil))
    }

    private func setSprite(_ value: String?) {
        subject?.set(sprite: value)
    }
}

// MARK: - Animator

class SpritesAnimator: TimedContentProvider<String> {
    static let none: SpritesAnimator = .init(baseName: "", frames: [], fps: 0)

    let baseName: String

    init(
        baseName: String,
        frames: [String],
        fps: TimeInterval,
        onFirstFrameLoaded: @escaping (Int) -> Void = { _ in },
        onLoopCompleted: @escaping (Int) -> Void = { _ in }
    ) {
        self.baseName = baseName
        super.init(
            frames: frames,
            fps: fps,
            onFirstFrameOfLoopLoaded: onFirstFrameLoaded,
            onLoopCompleted: onLoopCompleted
        )
    }
}
