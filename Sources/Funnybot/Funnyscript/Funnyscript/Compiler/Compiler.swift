import AVFoundation
import Foundation
//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Schwifty

public class Compiler {
    private let config: Config
    private let voices: VoicesProvider
    private let assets: AssetsProvider
    private let soundEffects: SoundEffectsProvider
    private let bannedActors = ["scene", "camera"]
    private let tag = "Compiler"
    
    lazy var addons: [any CompilerAddon] = {
        let addons: [CompilerAddon?] = [
            config.autoCharacterPlacement ? AutoPlacement() : nil,
            config.autoTurnToAction ? AutoTurn() : nil,
            config.useContextAwareAutoCamera ? AutoCameraContextAware() : nil,
            config.useLargeContextAwareAutoCamera ? AutoCameraLargeContextAware() : nil,
            config.useCloseUpsAutoCamera ? AutoCameraCloseUps() : nil
        ]
        return addons.compactMap { $0 }
    }()
    
    public init(config: Config, voices: VoicesProvider, assets: AssetsProvider, soundEffects: SoundEffectsProvider) {
        self.config = config
        self.voices = voices
        self.assets = assets
        self.soundEffects = soundEffects
    }
    
    public func compile(instructions: [Instruction]) async throws -> CompiledScript {
        Logger.debug(tag, "Compiling \(instructions.count) instructions...")
        var instructions = try await compiledInstructions(from: instructions)
        Logger.debug(tag, "Compiled!")
        
        addons.forEach {
            Logger.debug(tag, "Running addon `\($0.tag)`...")
            instructions = $0.patch(instructions)
        }
        Logger.debug(tag, "Done!")
        
        let duration = (instructions
            .map { $0.startTime + $0.duration }
            .max() ?? 0) + 1
        
        return CompiledScript(
            actors: actors(from: instructions),
            instructions: instructions,
            duration: duration
        )
    }
    
    private func actors(from instructions: [CompiledItem]) -> [String] {
        instructions
            .map { $0.instruction.subject }
            .removeDuplicates(keepOrder: false)
            .filter { !bannedActors.contains($0) }
            .sorted()
    }
    
    private func compiledInstructions(from instructions: [Instruction]) async throws -> [CompiledItem] {
        var compiled: [CompiledItem] = []
        var lastEndTime: TimeInterval = 0
        
        for line in instructions {
            let duration = try await duration(for: line)
            let timed = CompiledItem(
                instruction: line,
                practicalDuration: duration.practical,
                logicalDuration: duration.logical,
                startTime: lastEndTime
            )
            compiled.append(timed)
            lastEndTime += duration.practical
        }
        return compiled
    }
    
    private func duration(for line: Instruction) async throws -> ItemDuration {
        let practicalDuration: TimeInterval
        let logicalDuration: TimeInterval
        
        switch line.action {
        case .pause(let duration):
            practicalDuration = duration
            logicalDuration = practicalDuration
            
        case .animation(let id, let loops):
            practicalDuration = try await duration(actor: line.subject, animation: id, loops: loops)
            if loops == nil {
                let singleLoopDuration = try await duration(actor: line.subject, animation: id, loops: 1)
                logicalDuration = min(singleLoopDuration * 5, 6)
            } else {
                logicalDuration = practicalDuration
            }
            
        case .talking(let text, _):
            let audioDuration = try? await voices.duration(speaker: line.subject, text: text)
            practicalDuration = audioDuration ?? 1
            logicalDuration = practicalDuration
            
        default: 
            practicalDuration = 0
            logicalDuration = practicalDuration
        }
        
        return ItemDuration(practical: practicalDuration, logical: logicalDuration)
    }
    
    private func duration(actor: String, animation: String, loops: Int?) async throws -> TimeInterval {
        if actor == "overlay_video" { return 0 }
        guard let loops else { return 0 }
        let frames = assets.numberOfFrames(for: actor, animation: animation)
        let loopDuration = TimeInterval(frames) * config.frameTime
        let animationDuration = loopDuration * TimeInterval(loops)
        let audioDuration = (try? await audioDuration(actor: actor, animation: animation)) ?? 0
        return max(animationDuration, audioDuration)
    }
    
    private func audioDuration(actor: String, animation: String) async throws -> TimeInterval {
        try await soundEffects.duration(actor: actor, animation: animation)
    }
}

private struct ItemDuration {
    let practical: TimeInterval
    let logical: TimeInterval
}
