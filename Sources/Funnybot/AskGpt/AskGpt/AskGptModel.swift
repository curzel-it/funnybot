import Foundation

public enum AskGptModel: String, CaseIterable {
    case gpt3dot5turbo
    case gpt3dot5turbo16k
    case gpt4
    case gpt4with32k
    case mistral
    case mistralLarge
}

extension AskGptModel {
    public var name: String {
        switch self {
        case .gpt3dot5turbo: "GPT 3.5 Turbo (OpenAI)"
        case .gpt3dot5turbo16k: "GPT 3.5 Turbo 16k (OpenAI)"
        case .gpt4: "GPT 4 (OpenAI)"
        case .gpt4with32k: "GPT 4 32k (OpenRouter)"
        case .mistral: "Mistral Medium"
        case .mistralLarge: "Mistral Large"
        }
    }
    
    func buildChatApi(apiKey: String) -> ChatApi {
        switch self {
        case .gpt3dot5turbo: OpenAiChatCompletion(model: .turbo, authToken: apiKey)
        case .gpt3dot5turbo16k: OpenAiChatCompletion(model: .turbo16k, authToken: apiKey)
        case .gpt4: OpenAiChatCompletion(model: .gpt4, authToken: apiKey)
        case .gpt4with32k: OpenRouterChatCompletion(model: .gpt32k, authToken: apiKey)
        case .mistral: MistralChatCompletion(model: .medium, authToken: apiKey)
        case .mistralLarge: MistralChatCompletion(model: .large, authToken: apiKey)
        }
    }
}
