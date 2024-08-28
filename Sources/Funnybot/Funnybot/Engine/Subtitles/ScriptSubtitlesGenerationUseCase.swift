//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation
import Funnyscript

protocol ScriptSubtitlesGenerationUseCase {
    func subtitles(for script: String) async throws -> [SubtitleItem]
}

class ScriptSubtitlesGenerationUseCaseImpl: ScriptSubtitlesGenerationUseCase {
    @Inject private var audioSubtitles: AudioSubtitlesGenerationUseCase
    @Inject private var compiler: Funnyscript.Compiler
    @Inject private var dubs: DubsStorage
    @Inject private var parser: Funnyscript.Parser
        
    func subtitles(for script: String) async throws -> [SubtitleItem] {
        let instructions = try await parser.instructions(from: script)
        let compiled = try await compiler.compile(instructions: instructions)
        
        return try await compiled
            .instructions
            .asyncThrowingMap { [weak self] instruction -> [SubtitleItem] in
                guard let self else { return [] }
                return try await self.subtitles(from: instruction)
            }
            .flatMap { $0 }
            .enumerated()
            .map { (index, sub) in sub.with(index: index) }
    }
    
    func subtitles(from instruction: Funnyscript.CompiledItem) async throws -> [SubtitleItem] {
        if case .talking(let text, _) = instruction.instruction.action {
            // let url = dubs.dub(speaker: instruction.instruction.subject, line: text)
            // return try await subtitles(for: url, text: text)
            let item = SubtitleItem(
                index: 0,
                text: text,
                startTime: instruction.startTime,
                duration: instruction.duration
            )
            return [item]
        } else {
            return []
        }
    }
    
    func subtitles(for url: URL, text: String) async throws -> [SubtitleItem] {
        try await audioSubtitles.subtitles(for: url, originalText: text)
    }
}
