import BareBones
import Foundation
import Schwifty

class MistralChatCompletion: ChatApi {
    private let client: HttpClient
    private let chatCompletions = "v1/chat/completions"
    private let model: MistralModel
    private let tag = "MistralChatCompletion"
    
    var modelName: String {
        model.rawValue
    }
    
    init(model: MistralModel, authToken: String) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = model.timeout
        let session = URLSession(configuration: config)
        
        client = HttpClient(
            baseUrl: "https://api.mistral.ai",
            logResponses: true,
            session: session
        )
        self.model = model
        client.httpHeaders["Authorization"] = "Bearer \(authToken)"
        client.httpHeaders["HTTP-Referer"] = "https://curzel.it"
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

enum MistralModel: String, Codable {
    case tiny = "mistral-tiny"
    case small = "mistral-small"
    case medium = "mistral-medium"
    case large = "mistral-large-latest"
}

extension MistralModel {
    var timeout: TimeInterval {
        180
    }
}

private struct Request: Encodable {
    let model: MistralModel
    let messages: [Message]
    
    init(model: MistralModel, from history: [ChatMessage]) {
        self.model = model
        messages = history.map { Message(role: $0.role, content: $0.content) }
    }
}

private struct Message: Codable {
    let role: ChatRole
    let content: String
}

private struct Response: Decodable {
    let choices: [ResponseChoice]
    
    func bestEffortMessage() -> ChatMessage? {
        guard let choice = topPick() else { return nil }
        return ChatMessage(
            role: choice.message.role, 
            name: choice.message.role.rawValue.capitalized,
            date: Date(timeIntervalSince1970: 0),
            content: choice.message.content.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }
    
    private func topPick() -> ResponseChoice? {
        choices.first
    }
}

private struct ResponseChoice: Decodable {
    let message: Message
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
