//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation

public struct CompiledItem: Identifiable, CustomStringConvertible {
    public let id = UUID().uuidString
    
    public let instruction: Instruction
    public let practicalDuration: TimeInterval
    public let logicalDuration: TimeInterval
    public let startTime: TimeInterval
    
    public var duration: TimeInterval {
        practicalDuration
    }
    
    public var description: String {
        "\(instruction.description) T\(startTime) D\(duration)"
    }
    
    public init(instruction: Instruction, practicalDuration: TimeInterval, logicalDuration: TimeInterval, startTime: TimeInterval) {
        self.instruction = instruction
        self.practicalDuration = practicalDuration
        self.logicalDuration = logicalDuration
        self.startTime = startTime
    }
    
    public func expireTime(includeLoopingAnimations: Bool) -> TimeInterval {
        if includeLoopingAnimations, case .animation(_, let loops) = instruction.action, loops == nil {
            return .infinity
        }
        return startTime + logicalDuration + 1
    }
}
