//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation
import Funnyscript

protocol CallToActionsToScriptUseCase {
    func suggestions(for episode: Episode) async throws -> String
}

enum CallToActionOverlay: String, CaseIterable {
    case likeAndSubscribe = "like_and_subscribe"
    case leaveAComment = "leave_a_comment"
}

class CallToActionsToScriptUseCaseImpl: CallToActionsToScriptUseCase {
    @Inject private var model: GenerativeAiWorkingModel
    @Inject private var prompts: PromptBuilderUseCase
    @Inject private var indexedDialogs: IndexedDialogsUseCase
    
    func suggestions(for episode: Episode) async throws -> String {
        let dialogs = try await indexedDialogs.indexedDialogs(for: episode)
        let transcript = dialogs.transcript()
        
        let response = try await model.ask(prompt: systemPrompt(for: episode), question: transcript)
                
        return response
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isBlank }
            .compactMap {
                do {
                    let tokens = $0.components(separatedBy: ":")
                    let index = try Int(try tokens.first.unwrap()).unwrap()
                    let effect = try tokens.last.unwrap().trimmingCharacters(in: .whitespacesAndNewlines)
                    let command = "overlay_video: play \(effect) 1"
                    let item = try dialogs.first { $0.index == index }.unwrap()
                    return "\(item.subject): \"\(item.dialog)\"\n\(command)"
                } catch {
                    return nil
                }
            }
            .joined(separator: "\n\n")
    }
    
    func systemPrompt(for episode: Episode) -> String {
        prompts.build(
            templateName: "system_prompt_suggest_ctas",
            for: episode,
            userInput: availableItems(),
            notes: ""
        )
    }
    
    func availableItems() -> String {
        CallToActionOverlay.allCases
            .map { "* \($0.rawValue)" }
            .joined(separator: "\n")
    }
}
