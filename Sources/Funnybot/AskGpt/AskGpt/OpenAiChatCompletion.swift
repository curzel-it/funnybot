import BareBones
import Foundation
import Schwifty

class OpenAiChatCompletion: ChatApi {
    private let client: HttpClient
    private let chatCompletions = "v1/chat/completions"
    private let model: OpenAiModel
    private let tag = "OpenAiChatCompletion"
    
    var modelName: String {
        model.rawValue
    }
    
    init(model: OpenAiModel, authToken: String) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = model.timeout
        let session = URLSession(configuration: config)
                
        client = HttpClient(
            baseUrl: "https://api.openai.com",
            logResponses: true,
            session: session
        )
        self.model = model
        client.httpHeaders["Authorization"] = "Bearer \(authToken)"
    }
    
    func next(from history: [ChatMessage]) async -> Result<ChatMessage, Error> {
        let request = Request(model: model, from: history)
        let result = await response(for: request)
        
        switch result {
        case .success(let response):
            if let message = response.bestEffortMessage() {
                return .success(message)
            }
            return .failure(ChatApiError.noReply)
            
        case .failure(let error):
            return .failure(error)
        }
    }
    
    private func response(for request: Request) async -> Result<Response, Error> {
        let dataResponse = await client.data(via: .post, to: chatCompletions, with: .body(body: request))
        switch dataResponse {
        case .success(let data):
            return response(from: data)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    private func response(from data: Data) -> Result<Response, Error> {
        do {
            let response = try JSONDecoder().decode(Response.self, from: data)
            return .success(response)
        } catch {
            let dataString = String(data: data, encoding: .utf8) ?? "n/a"
            Logger.debug(tag, "Error: \(error) - Response: \(dataString)")
            
            if let response = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                return .failure(response.error)
            }
            return .failure(ChatApiError.unknown(content: dataString))
        }
    }
}

public enum OpenAiModel: String, Codable {
    case turbo = "gpt-3.5-turbo"
    case turbo16k = "gpt-3.5-turbo-16k"
    case gpt4 = "gpt-4"
}

extension OpenAiModel {
    var timeout: TimeInterval {
        switch self {
        case .turbo: 60
        case .turbo16k: 60
        case .gpt4: 120
        }
    }
}

private struct Request: Encodable {
    let model: OpenAiModel
    let messages: [Message]
    
    init(model: OpenAiModel, from history: [ChatMessage]) {
        self.model = model
        messages = history.map { Message(role: $0.role, content: $0.content) }
    }
}

private struct Message: Codable {
    let role: ChatRole
    let content: String
}

private struct Response: Decodable {
    let created: TimeInterval
    let choices: [ResponseChoice]
    
    func bestEffortMessage() -> ChatMessage? {
        guard let choice = topPick() else { return nil }
        return ChatMessage(
            role: choice.message.role,
            name: choice.message.role.rawValue,
            date: Date(timeIntervalSince1970: created),
            content: choice.message.content.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }
    
    private func topPick() -> ResponseChoice? {
        choices.sorted { $0.index < $1.index }.first
    }
}

private struct ResponseChoice: Decodable {
    let message: Message
    let index: Int
}

private struct ErrorResponse: Codable {
    let body: ErrorResponseBody
    
    var error: ChatApiError {
        switch body.code {
        case "invalid_api_key": .unauthorized
        default: .unknown(content: body.code)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case body = "error"
    }
}

private struct ErrorResponseBody: Codable {
    let code: String
}
