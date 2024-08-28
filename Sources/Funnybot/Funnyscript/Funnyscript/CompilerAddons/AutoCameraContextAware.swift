//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import AVFoundation
import Foundation
import Schwifty

class AutoCameraContextAware: CompilerAddon {
    let tag = "AutoCameraContextAware"
    
    private var focused: [FocusedSubject] = []
    
    private let windowSize: Int = 15
    private let maxFocusableCharacters: Int = 2
    private let bannedActors = ["scene", "camera", "overlay", "overlay_video", "overlay_blocking"]
    
    func patch(_ instructions: [CompiledItem]) -> [CompiledItem] {
        Logger.debug(tag, "Patching \(instructions.count) instructions...")
        var patched: [CompiledItem] = []
        var isFirstCameraMovementAfterReset = true
        focused.removeAll()
        
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
                    unfocus(subject, at: time)
                }
            }
            inactiveSubjects(currentTime: time, nextUp: nextUp).forEach {
                unfocus($0, at: time, wasInactive: true)
            }
            if shouldUnfocusAll(action) {
                focusChanged = true
                isFirstCameraMovementAfterReset = true
                unfocusAll(at: time)
            }
            trimFocused()
            
            if focusChanged {
                let camera = cameraInstruction(
                    at: instruction.startTime,
                    smoothly: !isFirstCameraMovementAfterReset
                )
                if !focused.isEmpty {
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
    
    private func trimFocused() {
        let values = focused.sorted { $0.isOverlay != $1.isOverlay ? $1.isOverlay : true }
        focused = [] + values[0..<min(values.count, maxFocusableCharacters)]
    }
    
    private func isFocused(_ subject: String) -> Bool {
        focused.contains { $0.subject == subject }
    } 
    
    private func focus(_ subject: String, instruction: CompiledItem) {
        Logger.debug(tag, timeTag(instruction.startTime), "Focused `\(subject)`")
        let item = FocusedSubject(subject: subject, instruction: instruction)
        focused.removeAll { $0.subject == subject }
        focused.append(item)
    }
    
    private func unfocus(_ subject: String, at time: TimeInterval, wasInactive: Bool = false) {
        let inactivity = wasInactive ? "due to inactivity" : ""
        Logger.debug(tag, timeTag(time), "Unfocused `\(subject)`", inactivity)
        focused.removeAll { $0.subject == subject }
    }
    
    private func unfocusAll(at time: TimeInterval) {
        Logger.debug(tag, timeTag(time), "Unfocusing all subjects")
        focused.removeAll()
    }
    
    private func shouldUnfocusAll(_ action: Action) -> Bool {
        action == .clearStage
    }
    
    private func inactiveSubjects(currentTime: TimeInterval, nextUp: [CompiledItem]) -> [String] {
        focused
            .filter { $0.isExpired(at: currentTime) }
            .filter { !containsFocusableAction(for: $0.subject, in: nextUp) }
            .map { $0.subject }
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
        let subjects = focused.map { $0.subject }
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
