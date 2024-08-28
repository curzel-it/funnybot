//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation
import Funnyscript

protocol ScriptGenerationUseCase {
    func continueDialog(for episode: Episode, notes: String) async throws -> String
}

enum ScriptGenerationUseCaseError: Error {
    case invalidResponse
    case ended
}

class ScriptGenerationUseCaseImpl: ScriptGenerationUseCase {
    @Inject var prompts: PromptBuilderUseCase
    @Inject var parser: Funnyscript.Parser
    @Inject var model: GenerativeAiWorkingModel
    
    func continueDialog(for episode: Episode, notes: String) async throws -> String {
        let systemPrompt = systemPrompt(episode: episode)
        let userPrompt = try await nextPromptRequest(episode: episode, notes: notes)
        
        let response = try await model
            .ask(prompt: systemPrompt, question: userPrompt)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "\"`:"))
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: CharacterSet(charactersIn: "\"")) }
            .joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ": \"", with: " \"")
            .replacingOccurrences(of: ": ", with: " ")
        
        if response.isBlank {
            try? await Task.sleep(for: .seconds(1))
            return try await continueDialog(for: episode, notes: notes)
        }        
        return response
    }
    
    func systemPrompt(episode: Episode) -> String {
        prompts.build(templateName: "system_prompt_interactive_script_generation_direct", for: episode)
    }
    
    func nextPromptRequest(episode: Episode, notes: String) async throws -> String {
        prompts.build(
            templateName: "user_prompt_interactive_script_generation_direct",
            for: episode,
            userInput: try await transcript(for: episode.script),
            notes: promptAdditions(fromNotes: notes)
        )
    }
    
    func transcript(for script: String) async throws -> String {
        try await parser
            .instructions(from: script)
            .compactMap { instruction in
                if case .talking(let line, _) = instruction.action {
                    "\(instruction.subject):\n\(line)"
                } else {
                    nil
                }
            }
            .joined(separator: "\n\n")
        
    }
    
    func promptAdditions(fromNotes notes: String) -> String {
        guard !notes.isEmpty else { return "" }
        return "Here's some notes from the director: \(notes)"
    }
}
