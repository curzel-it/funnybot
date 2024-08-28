//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation

public protocol CharactersProvider {
    func character(nameOrPath: String) async throws -> Character
}

public struct Character {
    public let name: String
    public let path: String
    public let afterTalkScript: String
    
    public init(
        name: String,
        path: String,
        afterTalkScript: String
    ) {
        self.name = name
        self.path = path
        self.afterTalkScript = afterTalkScript
    }
}
