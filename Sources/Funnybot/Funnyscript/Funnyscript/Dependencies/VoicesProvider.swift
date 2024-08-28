//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation

public protocol VoicesProvider {
    func duration(speaker: String, text: String) async throws -> TimeInterval
}

public enum VoicesProviderError: Error {
    case missingFile(url: URL)
}
