//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Combine
import SwiftUI

class FlipHorizontallyWhenGoingLeft: Capability {
    override func doUpdate(after time: TimeInterval) async {
        guard let subject else { return }
        flip(for: subject.direction, state: subject.state)
    }

    private func flip(for direction: CGVector, state: EntityState) {
        if case .action(let anim, _) = state, let animDirection = anim.facingDirection {
            flip(for: animDirection)
        } else {
            flip(for: direction)
        }
    }

    private func flip(for direction: CGVector) {
        let isGoingLeft = direction.dx < -0.0001
        subject?.rotation?.isFlippedHorizontally = isGoingLeft
    }
}
