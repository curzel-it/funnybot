//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation

extension Array {
    func randomElements(count: Int) -> [Element] {
        if count == 0 { return [] }
        if count >= self.count { return self }
        
        return self
            .enumerated()
            .map { (index, _) in index }
            .shuffled()
            .first(count)
            .map { self[$0] }
    }
}
