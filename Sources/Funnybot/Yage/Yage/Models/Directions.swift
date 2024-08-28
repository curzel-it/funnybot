//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation

public extension CGVector {
    static let left = CGVector(dx: -1, dy: 0)
    static let right = CGVector(dx: 1, dy: 0)
    static let front = CGVector.zero
    
    var isLateral: Bool {
        abs(dx) > 0.01
    }
}
