import Foundation
import Schwifty

open class AskGpt {
    private let chatApi: ChatApi
    
    public init(apiKey: String, model: AskGptModel) {
        Logger.debug("AskGpt", "Init with model:", model.name)
        self.chatApi = model.buildChatApi(apiKey: apiKey)
    }
    
    public func ask(prompt: String, question: String) async throws -> String {
        let history = [
            ChatMessage(role: .system, name: "GPT", content: prompt),
            ChatMessage(role: .user, name: "User", content: question)
        ]
        Logger.debug("AskGpt", "System Prompt: \(prompt)")
        Logger.debug("AskGpt", "Question: \(question)")
        Logger.debug("AskGpt", "Waiting for response...")
        
        let result = await chatApi.next(from: history)
        switch result {
        case .success(let success):
            Logger.debug("AskGpt", "Answer: \(success.content)")
            return success.content
        case .failure(let error):
            Logger.debug("AskGpt", "No answer! \(error)")
            throw error
        }
    }
    
    public func response(for history: [ChatMessage], prompt: String) async throws -> String {
        Logger.debug("AskGpt", "Prompt: \(prompt)")
        Logger.debug("AskGpt", "Waiting for response...")
        
        let fullHistory = history + [ChatMessage(role: .system, name: "System", content: prompt)]
        
        let result = await chatApi.next(from: fullHistory)
        switch result {
        case .success(let success):
            Logger.debug("AskGpt", "Answer: \(success.content)")
            return success.content
        case .failure(let error):
            Logger.debug("AskGpt", "No answer! \(error)")
            throw error
        }
    }
}
