//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation

public enum EntityState {
    case action(action: EntityAnimation, loops: Int? = nil)
    case move

    var description: String {
        switch self {
        case .action(let action, _): return action.id
        case .move: return "move"
        }
    }
}

// MARK: - Action State

public extension EntityState {
    var isAction: Bool {
        return if case .action(let animation, _) = self {
            !animation.isIdling
        } else {
            false
        }
    }
}

// MARK: - State Equatable

extension EntityState: Equatable {
    public static func == (lhs: EntityState, rhs: EntityState) -> Bool {
        lhs.description == rhs.description
    }
}
