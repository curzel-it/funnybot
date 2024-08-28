//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import AVFoundation
import Foundation
import Schwifty

class AutoPlacement: CompilerAddon {
    let tag = "AutoPlacement"
    
    private var handledCharacters: [String] = []
    private var lastPlacedCharacter: String?
    
    func patch(_ instructions: [CompiledItem]) -> [CompiledItem] {
        var patched: [CompiledItem] = []
        var sceneHandled = false
        
        for (index, instruction) in instructions.enumerated() {
            if case .clearStage = instruction.instruction.action {
                sceneHandled = false
            }
            if isCharacter(instruction.instruction.subject), !sceneHandled {
                Logger.debug(tag, timeTag(instruction.startTime), "Detected new scene")
                sceneHandled = true
                lastPlacedCharacter = nil
                handledCharacters = []
                let sceneInstructions = sceneInstructions(from: index, in: instructions)
                
                characters(in: sceneInstructions)
                    .compactMap { placementInstruction(for: $0, in: sceneInstructions) }
                    .forEach {
                        let action = $0.instruction.action
                        let subject = $0.instruction.subject
                        Logger.debug(tag, timeTag($0.startTime), "Placing `\(subject)` \(action)")
                        patched.append($0)
                    }
            }
            patched.append(instruction)
        }
        return patched
    }
    
    private func placementInstruction(for character: String, in instructions: [CompiledItem]) -> CompiledItem? {
        guard let action = placement(for: character, in: instructions) else { return nil }
        guard let startTime = instructions.first?.startTime else { return nil }
        
        return CompiledItem(
            instruction: Instruction(subject: character, action: action),
            practicalDuration: 0,
            logicalDuration: 0,
            startTime: startTime
        )
    }

    private func placement(for character: String, in instructions: [CompiledItem]) -> Action? {
        let characterInstructions = instructions.filter { $0.instruction.subject == character }
        guard !characterInstructions.isEmpty else { return nil }
        
        let hasPlacement = characterInstructions.contains { $0.instruction.action.isPlacement }
        guard !hasPlacement else { return nil }
        
        let firstActionIsWalking = firstActionIsWalking(among: characterInstructions)
        let firstWalkingDirection = firstWalkingDirection(among: characterInstructions)
        let timeToFirstNonWalkingAction = timeToFirstNonWalkingAction(among: characterInstructions)
                        
        if firstActionIsWalking {
            let position = initialScenePosition(walkTime: timeToFirstNonWalkingAction, direction: firstWalkingDirection)
            return .placement(destination: .scenePosition(position: position))
        } else {
            if let lastPlacedCharacter {
                self.lastPlacedCharacter = character
                return .placement(destination: .entity(id: lastPlacedCharacter))
            } else {
                lastPlacedCharacter = character
                return .placement(destination: .scenePosition(position: .centerLeft))
            }
        }
    }
    
    private func initialScenePosition(walkTime: TimeInterval, direction: WalkingDirection) -> ScenePosition {
        let isGoingRight = direction == .right
        
        return switch true {
        case walkTime < 1: isGoingRight ? .midRight : .midLeft
        case walkTime < 3: isGoingRight ? .farRight : .farLeft
        default: isGoingRight ? .outsideRight : .outsideLeft
        }
    }
    
    private func firstActionIsWalking(among instructions: [CompiledItem]) -> Bool {
        instructions
            .filter {
                switch $0.instruction.action {
                case .animation: true
                case .movement: true
                case .talking: true
                default: false
                }
            }
            .first?
            .instruction.action.isMovement ?? false
    }
    
    private func timeToFirstNonWalkingAction(among instructions: [CompiledItem]) -> TimeInterval {
        instructions
            .filter {
                switch $0.instruction.action {
                case .animation: true
                case .talking: true
                default: false
                }
            }
            .first?
            .startTime ?? 0
    }
    
    private func firstWalkingDirection(among instructions: [CompiledItem]) -> WalkingDirection {
        instructions
            .compactMap {
                switch $0.instruction.action {
                case .movement(let destination, _):
                    if case .scenePosition(let position) = destination {
                        return position.isOnRightOrCenter ? .right : .left
                    }
                    return .right
                default: return nil
                }
            }
            .first ?? .right
    }
}

private enum WalkingDirection {
    case left
    case right
}

private struct Scene {
    let startIndex: Int
    let startTime: TimeInterval
    let instructions: [CompiledItem]
    let characters: [String]
    
    private static let bannedCharacters = ["scene", "overlay", "overlay_video", "overlay_blocking", "camera"]
    
    init(startIndex: Int, instructions: [CompiledItem]) {
        self.startIndex = startIndex
        self.startTime = instructions.first?.startTime ?? 0
        self.instructions = instructions
        
        self.characters = instructions
            .map { $0.instruction.subject }
            .filter { !Scene.bannedCharacters.contains($0) }
            .removeDuplicates(keepOrder: true)
    }
}
