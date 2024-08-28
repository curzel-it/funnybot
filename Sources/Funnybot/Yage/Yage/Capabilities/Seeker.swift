//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Schwifty
import SwiftUI

public protocol SeekerTarget {
    var frame: CGRect { get }
}

extension Entity: SeekerTarget {}

extension CGPoint: SeekerTarget {
    public var frame: CGRect {
        CGRect(origin: self, size: .oneByOne)
    }
}

public class Seeker: Capability {
    private var target: SeekerTarget?
    private var targetPosition: Position = .center
    private var targetOffset: CGSize = .zero
    private var minDistance: CGFloat = 0.1
    private var maxDistance: CGFloat = 20
    private var targetReached: Bool = false
    private var continuously: Bool = false
    private var report: (State) -> Void = { _ in }

    // MARK: - Follow

    public func follow(
        _ target: SeekerTarget,
        to targetPosition: Position,
        offset: CGSize = .zero,
        maxDistance: CGFloat = 20,
        continuously: Bool = false,
        report: @escaping (State) -> Void = { _ in }
    ) {
        guard let subject else { return }
        self.continuously = continuously
        self.minDistance = subject.speed / Config.shared.fps
        self.maxDistance = maxDistance
        self.report = report
        self.target = target
        self.targetOffset = offset
        self.targetPosition = targetPosition
    }

    // MARK: - Update

    public override func doUpdate(after time: TimeInterval) async {
        guard let subject else { return }
        guard let target = targetPoint() else { return }
        
        if subject.state != .move {
            subject.set(state: .move)
        }
        let distance = subject.frame.origin.distance(from: target)
        
        checkTargetReached(with: distance)
        adjustDirection(towards: target, with: distance)
    }

    // MARK: - Destination Reached

    private func checkTargetReached(with distance: CGFloat) {
        if !targetReached {
            if distance <= minDistance && !continuously {
                targetReached = true
                report(.captured)
                subject?.resetSpeed()
            } else {
                let state = Seeker.State.following(distance: distance)
                report(state)
            }
        } else if distance >= maxDistance && targetReached {
            targetReached = false
            report(.escaped)
        }
    }

    // MARK: - Direction
    
    private func adjustDirection(towards target: CGPoint, with distance: CGFloat) {
        guard let subject else { return }
        let direction = linearDirection(towards: target, with: distance)
        subject.set(direction: direction)
    }
    
    private func linearDirection(towards target: CGPoint, with distance: CGFloat) -> CGVector {
        guard let subject else { return .zero }
        if distance < minDistance {
            return .zero
        } else {
            return .unit(from: subject.frame.origin, to: target)
        }
    }

    // MARK: - Target Location

    private func targetPoint() -> CGPoint? {
        guard let frame = subject?.frame else { return nil }
        guard let targetFrame = target?.frame else { return nil }

        let centerX = targetFrame.midX - frame.width / 2
        let centerY = targetFrame.midY - frame.height / 2

        switch targetPosition {
        case .match:
            return targetFrame.origin
        case .center:
            return CGPoint(
                x: centerX + targetOffset.width,
                y: centerY + targetOffset.height
            )
        case .above:
            return CGPoint(
                x: centerX + targetOffset.width,
                y: targetFrame.minY - frame.height + targetOffset.height
            )
        }
    }

    // MARK: - Uninstall

    public override func kill(autoremove: Bool = true) {
        target = nil
        report = { _ in }
        if let subject, subject.isAlive {
            subject.set(state: .action(action: .idling))
        }
        super.kill(autoremove: autoremove)
    }
}

extension Seeker {
    public enum Position {
        case match
        case center
        case above
    }
}

extension Seeker {
    public enum State: Equatable, CustomStringConvertible {
        case captured
        case escaped
        case following(distance: CGFloat)

        public var description: String {
            switch self {
            case .captured: return "Captured"
            case .escaped: return "Escaped"
            case .following(let distance):
                return "Following... \(String(format: "%0.2f", distance))"
            }
        }
    }
}
