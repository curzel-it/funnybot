import Foundation

public enum ChatRole: String, Codable, Hashable {
    case application
    case system
    case user
    case assistant
    
    var isApiRole: Bool {
        self == .user || self == .system || self == .assistant
    }
}
