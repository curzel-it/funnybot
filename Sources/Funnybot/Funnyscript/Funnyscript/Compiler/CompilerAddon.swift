//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation

protocol CompilerAddon {
    var tag: String { get }
    
    func patch(_ instructions: [CompiledItem]) -> [CompiledItem]
}

extension CompilerAddon {
    func isCharacter(_ subject: String) -> Bool {
        !["scene", "overlay", "overlay_video", "overlay_blocking", "camera"].contains(subject)
    }
    
    func timeTag(_ time: TimeInterval) -> String {
        String(format: "%0.2fs", time)
    }
    
    func characters(in instructions: [CompiledItem]) -> [String] {
        instructions
            .map { $0.instruction.subject }
            .filter { isCharacter($0) }
            .removeDuplicates(keepOrder: true)
    }
    
    func sceneInstructions(from startIndex: Int, in instructions: [CompiledItem]) -> [CompiledItem] {
        let remainingInstructions = Array(instructions[startIndex..<instructions.count])
        
        for (index, instruction) in remainingInstructions.enumerated() {
            if case .clearStage = instruction.instruction.action {
                return Array(remainingInstructions[0..<index])
            }
        }
        return remainingInstructions
    }
    
    func sceneInstructions(around index: Int, in instructions: [CompiledItem]) -> [CompiledItem] {
        let nearestClearIndex = Array(instructions[0..<index])
            .enumerated()
            .reversed()
            .first { $0.1.instruction.action.isClearStage }?.0
        
        let startIndex = nearestClearIndex.let { $0 + 1 } ?? index
        return sceneInstructions(from: startIndex, in: instructions)
    }
}
