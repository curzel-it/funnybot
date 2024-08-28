//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation
import Schwifty

public class ListCharactersUseCase {
    private let characters: CharactersProvider
    
    public init(characters: CharactersProvider) {
        self.characters = characters
    }
    
    public func listCharacters(in instructions: [Instruction]) -> [String] {
        instructions
            .map { $0.subject }
            .sorted()
            .removeDuplicates(keepOrder: true)
            .by(removing: "scene")
            .by(removing: "overlay")
            .by(removing: "overlay_video")
            .by(removing: "overlay_blocking")
    }
    
    public func listMissingCharacters(in instructions: [Instruction]) async -> [String] {
        await listCharacters(in: instructions)
            .asyncFilter { [weak self] name in
                let character = try? await self?.characters.character(nameOrPath: name)
                return character == nil
            }
    }
}
