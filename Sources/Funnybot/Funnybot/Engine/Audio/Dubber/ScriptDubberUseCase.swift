//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Combine
import Foundation
import Funnyscript
import Schwifty

protocol ScriptDubberUseCase {
    func dubAllLines(in script: [Instruction], episode: Episode, handler: @escaping DubberProgressHandler) async throws
}

enum ScriptDubberUseCaseError: Error {
    case seriesNotFound
}

class ScriptDubberUseCaseImpl: ScriptDubberUseCase {
    @Inject private var voices: VoiceSynthesizer
    
    private let tag = "ScriptDubberUseCaseImpl"
    
    func dubAllLines(in script: [Instruction], episode: Episode, handler: @escaping DubberProgressHandler) async throws {
        guard let series = episode.series else {
            Logger.error(tag, "Series not found!?")
            throw ScriptDubberUseCaseError.seriesNotFound
        }
        
        let requiredDubs = dubs(in: script)
        let total = requiredDubs.count
        
        let customModels = series.characters?
            .reduce(into: [String: String]()) { partialResult, character in
                partialResult[character.species().nickname] = character.customVoiceModel
            } ?? [:]
        
        Logger.debug(tag, "Need to dub \(total) lines")
        Logger.debug(tag, "Using \(type(of: voices))")
        
        for (index, line) in requiredDubs.enumerated() {
            Logger.debug(tag, "Dubbing \(index) of \(total)...")
            handler(Float(index)/Float(total))
            let model = customModels[line.0]
            _ = try await voices.synthesize(series: series, speaker: line.0, text: line.1, customModelName: model)
        }
    }
    
    func dubs(in script: [Instruction]) -> [(String, String)] {
        script
            .compactMap { instruction in
                if case .talking(let line, _) = instruction.action {
                    return (instruction.subject, line)
                }
                return nil
            }
    }
}
