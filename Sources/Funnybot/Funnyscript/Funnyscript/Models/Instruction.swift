//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation

public struct Instruction: Equatable, CustomStringConvertible {
    public let subject: String
    public let action: Action
    
    public var description: String {
        "\(subject): \(action)"
    }
    
    public init(subject: String, action: Action) {
        self.subject = subject
        self.action = action
    }
}
