//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Schwifty
import SwiftUI

class LinearMovement: Capability {
    override func doUpdate(after time: TimeInterval) async {
        guard let subject, subject.state.canMove else { return }
        let distance = movement(after: time)
        let newPosition = subject.frame.origin.offset(by: distance)
        subject.set(position: newPosition)
    }

    func movement(after time: TimeInterval) -> CGPoint {
        guard let subject else { return .zero }
        return CGPoint(
            x: subject.direction.dx * subject.speed * time,
            y: subject.direction.dy * subject.speed * time
        )
    }
}

extension Entity {
    var movement: LinearMovement? {
        capability(for: LinearMovement.self)
    }
}

private extension EntityState {
    var canMove: Bool {
        self == .move
    }
}
