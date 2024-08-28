//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import AVFoundation
import Foundation
import Schwifty

class AutoCameraCloseUps: CompilerAddon {
    let tag = "AutoCameraCloseUps"
    
    private var focused: FocusedSubject?
    
    private let windowSize: Int = 15
    private let bannedActors = ["scene", "camera", "overlay", "overlay_video", "overlay_blocking"]
    
    func patch(_ instructions: [CompiledItem]) -> [CompiledItem] {
        Logger.debug(tag, "Patching \(instructions.count) instructions...")
        var patched: [CompiledItem] = []
        var isFirstCameraMovementAfterReset = true
        focused = nil
        
        for (index, instruction) in instructions.enumerated() {
            patched.append(instruction)
            let time = instruction.startTime
            Logger.debug(tag, timeTag(time), "Handling `\(instruction.instruction)`")
            let action = instruction.instruction.action
            let nextUp = batch(from: index+1, in: instructions)
            let subject = instruction.instruction.subject
            
            var focusChanged = false
            
            if !bannedActors.contains(subject) {
                if shouldFocus(currentAction: action, actor: subject) {
                    focusChanged = true
                    focus(subject, instruction: instruction)
                }
                if isFocused(subject), shouldUnfocus(given: action) {
                    focusChanged = true
                    focused = nil
                }
            }
            if currentSubjectWillBeInactive(nextUp: nextUp) {
                focused = nil
            }
            if shouldUnfocusAll(action) {
                focusChanged = true
                isFirstCameraMovementAfterReset = true
                focused = nil
            }
            
            if focusChanged {
                let camera = cameraInstruction(
                    at: instruction.startTime,
                    smoothly: !isFirstCameraMovementAfterReset
                )
                if focused != nil {
                    isFirstCameraMovementAfterReset = false
                }
                patched.append(camera)
            }
            
            if shouldStopAutoCamera(given: instruction) {
                break
            }
        }
        
        return patched
    }
    
    private func shouldStopAutoCamera(given instruction: CompiledItem) -> Bool {
        guard instruction.instruction.subject == "overlay" else { return false }
        if case .animation(let id, _) = instruction.instruction.action {
            return id == "endcard"
        }
        return false
    }
    
    private func isFocused(_ subject: String) -> Bool {
        focused?.subject == subject
    }
    
    private func focus(_ subject: String, instruction: CompiledItem) {
        Logger.debug(tag, timeTag(instruction.startTime), "Focused `\(subject)`")
        let item = FocusedSubject(subject: subject, instruction: instruction)
        focused = item
    }
    
    private func shouldUnfocusAll(_ action: Action) -> Bool {
        action == .clearStage
    }
    
    private func currentSubjectWillBeInactive(nextUp: [CompiledItem]) -> Bool {
        guard let subject = focused?.subject else { return true }
        return !containsFocusableAction(for: subject, in: nextUp)
    }
    
    private func containsFocusableAction(for subject: String, in instructions: [CompiledItem]) -> Bool {
        instructions
            .filter { $0.instruction.subject == subject }
            .contains { shouldFocus(futureAction: $0.instruction.action) }
    }
    
    private func shouldFocus(currentAction action: Action, actor: String) -> Bool {
        switch action {
        case .talking: true
        case .movement(let destination, _): destination.isInsideScene
        case .animation(_, let loops):
            if actor == "overlay" {
                loops != nil
            } else {
                true
            }
        default: false
        }
    }
    
    private func shouldFocus(futureAction action: Action) -> Bool {
        switch action {
        case .talking: true
        case .animation: true
        default: false
        }
    }
    
    private func shouldUnfocus(given action: Action) -> Bool {
        switch action {
        case .movement(let destination, _): !destination.isInsideScene
        default: false
        }
    }
    
    private func batch(from startIndex: Int, in values: [CompiledItem]) -> [CompiledItem] {
        guard startIndex < values.count else { return [] }
        
        var endIndex = min(startIndex+windowSize, values.count)
        for (index, value) in values[startIndex..<endIndex].enumerated() {
            if case .clearStage = value.instruction.action {
                endIndex = index
            }
        }
        if endIndex <= startIndex { return [values[startIndex]] }
        return Array(values[startIndex..<endIndex])
    }
    
    private func cameraInstruction(at time: TimeInterval, smoothly: Bool) -> CompiledItem {
        let subjects = [focused?.subject].compactMap { $0 }
        let focusedNames = subjects.joined(separator: ", ")
        
        if subjects.isEmpty {
            Logger.debug(tag, timeTag(time), "Focusing camera on whole scene")
        } else {
            Logger.debug(tag, timeTag(time), "Focusing camera on \(focusedNames)")
        }
        
        let instruction = Instruction(
            subject: "camera",
            action: .camera(view: .entities(names: subjects), smoothly: smoothly)
        )
        return CompiledItem(
            instruction: instruction,
            practicalDuration: 0,
            logicalDuration: 0,
            startTime: time
        )
    }
}

private struct FocusedSubject {
    let subject: String
    let instruction: CompiledItem
    
    var isOverlay: Bool {
        subject == "overlay" || subject == "overlay_video" || subject == "overlay_blocking"
    }
    
    var isPlayingText: Bool {
        if case .animation(let id, _) = instruction.instruction.action {
            id.contains("text")
        } else {
            false
        }
    }
    
    func isExpired(at time: TimeInterval) -> Bool {
        instruction.expireTime(includeLoopingAnimations: false) <= time
    }
}
