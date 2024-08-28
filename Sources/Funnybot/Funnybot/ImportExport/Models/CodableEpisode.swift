//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation

struct CodableEpisode: Codable {
    let title: String
    let number: Int
    let concept: String
    let script: String
    
    init(from model: Episode?) throws {
        guard let model else {
            throw ImportExportError.uncodable(model: "Episode")
        }
        title = model.title
        number = model.number
        concept = model.concept
        script = model.script
    }

    func asModel() -> Episode {
        let model = Episode()
        model.title = title
        model.number = number
        model.concept = concept
        model.script = script
        return model
    }
}
