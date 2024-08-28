//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation
import Schwifty
import SwiftData

protocol DubsStorage {
    @discardableResult
    func save(speaker: String, line: String, data: Data) throws -> URL
    func dub(speaker: String, line: String) -> URL
    func hasDub(speaker: String, line: String) -> Bool
    func delete(speaker: String, line: String)
}

class FileBasedDubsStorage: DubsStorage {
    @Inject private var modelContainer: ModelContainer
    @Inject private var configStorage: ConfigStorageService
    
    var config: Config {
        configStorage.current
    }
    
    var fileManager: FileManager {
        FileManager.default
    }
    
    private let tag = "FileBasedDubsStorage"
    
    @discardableResult
    func save(speaker: String, line: String, data: Data) throws -> URL {
        let url = dub(speaker: speaker, line: line)
        try data.write(to: url)
        return url
    }
    
    func dub(speaker: String, line: String) -> URL {
        let filename = filename(speaker: speaker, line: line)
        return config.dubsFolder.appending(path: filename, directoryHint: .notDirectory)
    }
    
    func hasDub(speaker: String, line: String) -> Bool {
        let url = dub(speaker: speaker, line: line)
        return fileManager.fileExists(at: url)
    }
    
    func delete(speaker: String, line: String) {
        let url = dub(speaker: speaker, line: line)
        try? fileManager.removeItem(at: url)
    }
    
    private func filename(speaker: String, line: String) -> String {
        "\(speaker): \(line)"
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .md5() + ".m4a"
    }
}
