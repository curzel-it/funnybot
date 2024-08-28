//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation
import AskGpt

class GenerativeAiModel {
    private let model: AskGpt
    
    init(model: AskGpt) {
        self.model = model
    }
    
    func ask(prompt: String, question: String) async throws -> String {
        let response = try await model.ask(prompt: prompt, question: question)
        return clean(text: response)
    }
    
    func response(for history: [ChatMessage], prompt: String) async throws -> String {
        let response = try await model.response(for: history, prompt: prompt)
        return clean(text: response)
    }
    
    private func clean(text: String) -> String {
        let cleaned = text
            .replacingOccurrences(of: "funnyscript", with: "")
            .replacingOccurrences(of: "Funnyscript", with: "")
            .replacingOccurrences(of: "FunnyScript", with: "")
            .trimmingCharacters(in: CharacterSet(charactersIn: "` \n\t"))
        
        let tokens = cleaned
            .components(separatedBy: "```")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        switch tokens.count {
        case 1: return tokens[0]
        case 2:
            let firstTokenIsBlank = tokens[0].isBlank
            let firstTokenIsHeader = tokens[0].hasSuffix(":")
            let skipFirstToken = firstTokenIsBlank || firstTokenIsHeader
            return skipFirstToken ? tokens[1] : tokens[0]
        case 3: return tokens[1]
        case 4: return tokens[3]
        default: return cleaned
        }
    }
}

class GenerativeAiChatModel: GenerativeAiModel {
    init() {
        @Inject var modelPreferences: GenerativeModelPreferencesUseCase
        let model = modelPreferences.chatModel()
        let gpt = AskGpt(apiKey: model.key(), model: model)
        super.init(model: gpt)
    }
}

class GenerativeAiWorkingModel: GenerativeAiModel {
    init() {
        @Inject var modelPreferences: GenerativeModelPreferencesUseCase
        let model = modelPreferences.workingModel()
        let gpt = AskGpt(apiKey: model.key(), model: model)
        super.init(model: gpt)
    }
}

private extension AskGptModel {
    func key() -> String {
        @Inject var storage: ApiKeysStorageUseCase
        
        return switch self {
        case .gpt3dot5turbo, .gpt3dot5turbo16k, .gpt4: storage.apiKey(for: .openAi)
        case .gpt4with32k: storage.apiKey(for: .openRouter)
        case .mistral, .mistralLarge: storage.apiKey(for: .mistral)
        }
    }
}
