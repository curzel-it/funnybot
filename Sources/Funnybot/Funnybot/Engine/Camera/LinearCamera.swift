//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation
import Schwifty

class LinearCamera: Camera {
    @Inject private var configStorage: ConfigStorageService
    
    private(set) var viewport: CGRect = .zero
    private var nextTarget: CGRect = .zero
    private var step: RectDiff = (x: 0, y: 0, width: 0, height: 0)
    private var nextDestination: CGRect = .zero
    private var numberOfUpdateFramesLeft: Int = -1
    private var originalSize: CGSize = .zero
    
    var config: Config {
        configStorage.current
    }
    
    var numberOfUpdateFramesPerTransition: Int {
        config.cameraTransitionDuration
    }
    
    private let tag = "Camera"
    
    init() {
        originalSize = config.sceneSize
        reset()
    }
    
    func reset() {
        viewport = .init(size: config.sceneSize)
        nextDestination = viewport
        numberOfUpdateFramesLeft = -1
    }
    
    func transition(to destination: CGRect, smoothly: Bool) {
        let scaledDestination = CGRect(
            x: max(destination.origin.x, 0),
            y: max(destination.origin.y, 0),
            width: min(destination.width, originalSize.width),
            height: min(destination.height, originalSize.height)
        )
        if nextTarget == scaledDestination {
            Logger.debug(tag, "Skipping additional transition (\(destination.viewportString))")
            return
        }
        if viewport == scaledDestination {
            Logger.debug(tag, "Already in place \(destination.viewportString)")
            return
        }
        nextTarget = scaledDestination
        
        if !smoothly {
            Logger.debug(tag, "Cut to \(destination.viewportString)")
            viewport = scaledDestination
        } else {
            Logger.debug(tag, "Started transition to \(destination.viewportString)")
            transitionSmoothly(to: scaledDestination)
        }
    }
    
    private func transitionSmoothly(to destination: CGRect) {
        let delta = delta(to: destination)
        let totalSteps = CGFloat(numberOfUpdateFramesPerTransition)
        
        step = (
            x: delta.x / totalSteps,
            y: delta.y / totalSteps,
            width: delta.width / totalSteps,
            height: delta.height / totalSteps
        )
        nextDestination = destination
        numberOfUpdateFramesLeft = numberOfUpdateFramesPerTransition
    }
    
    func update(after timeSinceLastUpdate: TimeInterval) {
        guard numberOfUpdateFramesLeft != -1 else { return }
        
        if numberOfUpdateFramesLeft == 0 {
            viewport = nextDestination
        } else {
            if config.renderingMode == .pixelArt {
                viewport = CGRect(
                    x: CGFloat(Int(viewport.origin.x + step.x)),
                    y: CGFloat(Int(viewport.origin.y + step.y)),
                    width: CGFloat(Int(viewport.width + step.width)),
                    height: CGFloat(Int(viewport.height + step.height))
                )
            } else {
                viewport = CGRect(
                    x: CGFloat(viewport.origin.x + step.x),
                    y: CGFloat(viewport.origin.y + step.y),
                    width: CGFloat(viewport.width + step.width),
                    height: CGFloat(viewport.height + step.height)
                )
            }
        }
        numberOfUpdateFramesLeft -= 1
    }
        
    private func delta(to destination: CGRect) -> RectDiff {
        (
            x: destination.origin.x - viewport.origin.x,
            y: destination.origin.y - viewport.origin.y,
            width: destination.width - viewport.width,
            height: destination.height - viewport.height
        )
    }
}
