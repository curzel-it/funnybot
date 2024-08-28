import BareBones
import Foundation
import Schwifty

protocol ChatApi {
    var modelName: String { get }
    
    func next(from history: [ChatMessage]) async -> Result<ChatMessage, Error>
}

enum ChatApiError: Error {
    case unauthorized
    case noReply
    case unknown(content: String)
}
