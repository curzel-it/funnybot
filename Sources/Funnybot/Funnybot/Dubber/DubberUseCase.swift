//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation
import Funnyscript
import Combine

struct DialogLine: Identifiable {
    let id: String
    let speaker: String
    let line: String
    let url: URL
    let isDubbed: Bool
    
    init(speaker: String, line: String, url: URL, isDubbed: Bool) {
        self.speaker = speaker
        self.line = line
        self.url = url
        self.isDubbed = isDubbed
        self.id = "\(speaker) \(line)"
    }
}

protocol DubberUseCase {
    func dialogLines(from script: String) async -> [DialogLine]
    func lines(from script: String) async -> [(String, String)]
    func generateDub(for line: DialogLine, episode: Episode) async throws
    func generateDubs(for episode: Episode, handler: @escaping DubberProgressHandler) async throws
    func deleteDub(for line: DialogLine)
}

class DubberUseCaseImpl: DubberUseCase {
    @Inject private var app: AppViewModel
    @Inject private var parser: Parser
    @Inject private var dubsStorage: DubsStorage
    @Inject private var episodeDubber: EpisodeDubberUseCase
    @Inject private var voices: VoiceSynthesizer
    
    private var disposables = Set<AnyCancellable>()
    
    func dialogLines(from script: String) async -> [DialogLine] {
        await lines(from: script)
            .map { (speaker, line) in
                let url = dubsStorage.dub(speaker: speaker, line: line)
                let isDubbed = dubsStorage.hasDub(speaker: speaker, line: line)
                return DialogLine(speaker: speaker, line: line, url: url, isDubbed: isDubbed)
            }
    }
    
    func lines(from script: String) async -> [(String, String)] {
        guard let instructions = try? await parser.instructions(from: script) else { return [] }
        
        return instructions
            .compactMap { instruction -> (String, String)? in
                if case .talking(let line, _) = instruction.action {
                    (instruction.subject, line)
                } else {
                    nil
                }
            }
    }
    
    func generateDub(for line: DialogLine, episode: Episode) async throws {
        guard let series = episode.series else { return }
        
        let model = series.characters?
            .first { $0.species().nickname == line.speaker }?
            .customVoiceModel
        
        _ = try await voices.synthesize(
            series: series,
            speaker: line.speaker,
            text: line.line,
            customModelName: model
        )
    }
    
    func generateDubs(for episode: Episode, handler: @escaping DubberProgressHandler) async throws {
        try await episodeDubber.dubAllLines(of: episode, handler: handler)
    }
    
    func deleteDub(for line: DialogLine) {
        dubsStorage.delete(speaker: line.speaker, line: line.line)
    }
}
