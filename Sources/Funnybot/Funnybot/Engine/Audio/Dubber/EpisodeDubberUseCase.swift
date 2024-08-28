//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Combine
import Foundation
import Funnyscript
import Schwifty

protocol EpisodeDubberUseCase {
    func dubAllLines(of episode: Episode, handler: @escaping DubberProgressHandler) async throws
}

typealias DubberProgressHandler = (Float) -> Void

class EpisodeDubberUseCaseImpl: EpisodeDubberUseCase {
    @Inject private var parser: Funnyscript.Parser
    @Inject private var scriptDubber: ScriptDubberUseCase
    
    private let tag = "EpisodeDubberUseCaseImpl"
    
    func dubAllLines(of episode: Episode, handler: @escaping DubberProgressHandler) async throws {
        Logger.debug(tag, "Dubbing episode...")
        let script = try await parser.instructions(from: episode.script)
        try await scriptDubber.dubAllLines(in: script, episode: episode, handler: handler)
    }
}
