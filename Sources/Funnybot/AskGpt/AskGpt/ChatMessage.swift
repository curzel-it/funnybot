import Foundation

public struct ChatMessage: Codable, Hashable {
    public let date: Date
    public let role: ChatRole
    public let name: String
    public let content: String
        
    public init(role: ChatRole, name: String, date: Date = Date(), content: String) {
        self.name = name
        self.role = role
        self.date = date
        self.content = content
    }
}
