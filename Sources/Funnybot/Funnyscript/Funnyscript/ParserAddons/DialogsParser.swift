//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation

class DialogsParser: ParserAddon {
    private let charactersProvider: CharactersProvider
    private let config: Config
    
    init(config: Config, charactersProvider: CharactersProvider) {
        self.charactersProvider = charactersProvider
        self.config = config
    }
    
    func instructions(from text: String, subject: String) async throws -> [Instruction]? {
        let character = await character(for: subject)
        let tokens = text.components(separatedBy: "\"")
        guard tokens.count == 3 else { return nil }
        
        let line = tokens[1].trimmingCharacters(in: .whitespaces)
        let info = tokens[2].trimmingCharacters(in: .whitespaces)
        let talk = Instruction(subject: subject, action: .talking(line: line, info: info))
        
        if let script = character?.afterTalkScript {
            let parser = Parser(config: config, charactersProvider: charactersProvider)
            let extras = try await parser.instructions(from: script)
            return [talk] + extras
        }
        return [talk]
    }
    
    func character(for subject: String) async -> Character? {
        try? await charactersProvider.character(nameOrPath: subject)
    }
}
