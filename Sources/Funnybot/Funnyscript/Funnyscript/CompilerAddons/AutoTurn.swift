//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import AVFoundation
import Foundation
import Schwifty

class AutoTurn: CompilerAddon {
    let tag = "AutoTurn"
    
    func patch(_ instructions: [CompiledItem]) -> [CompiledItem] {
        var patched: [CompiledItem] = []
        
        for (index, instruction) in instructions.enumerated() {
            let subject = instruction.instruction.subject
            let action = instruction.instruction.action
            let time = instruction.startTime
            patched.append(instruction)
            
            if isCharacter(subject), isNoteworthy(action) {
                let sceneInstructions = sceneInstructions(around: index, in: instructions)
                
                let characters = sceneInstructions
                    .map { $0.instruction.subject }
                    .removeDuplicates(keepOrder: false)
                    .filter { $0 != subject }
                    .filter { isCharacter($0) }
                    .filter { !isBusy(character: $0, given: sceneInstructions, at: time) }
                    .sorted()
                
                characters.forEach {
                    let turn = turnInstruction(subject: $0, target: subject, at: time)
                    Logger.debug(tag, timeTag(time), "Added turn: \(turn)")
                    patched.append(turn)
                }
            }
        }
        return patched
    }
    
    private func isBusy(character: String, given instructions: [CompiledItem], at time: TimeInterval) -> Bool {
        let latestBusyEndTime = instructions
            .filter { $0.instruction.subject == character }
            .filter { Int($0.startTime * 100) <= Int(time * 100) }
            .filter { $0.instruction.action.isAnimation }
            .map { $0.expireTime(includeLoopingAnimations: true) }
            .max() ?? 0
        return latestBusyEndTime > time
    }
    
    private func turnInstruction(subject: String, target: String, at time: TimeInterval) -> CompiledItem {
        CompiledItem(
            instruction: .init(subject: subject, action: .turn(target: .entity(id: target))),
            practicalDuration: 0,
            logicalDuration: 0,
            startTime: time
        )
    }
    
    private func isNoteworthy(_ action: Action) -> Bool {
        switch action {
        case .animation: true
        case .talking: true
        default: false
        }
    }
}
