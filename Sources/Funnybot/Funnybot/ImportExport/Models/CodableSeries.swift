//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation

struct CodableSeries: Codable {
    let title: String
    let about: String
    let style: String
    let scriptInit: String
    let characters: [CodableSeriesCharacter]
    let episodes: [CodableEpisode]
    
    init(from model: Series?) throws {
        guard let model else {
            throw ImportExportError.uncodable(model: "Series")
        }
        title = model.title
        about = model.about
        style = model.style
        scriptInit = model.scriptInit
        
        characters = try model.characters.unwrap()
            .map { try CodableSeriesCharacter(from: $0) }
            .sorted { $0.name < $1.name }

        episodes = try model.episodes.unwrap()
            .map { try CodableEpisode(from: $0) }
            .sorted { $0.number < $1.number }
    }

    func asModel() -> Series {
        let model = Series()
        model.title = title
        model.about = about
        model.style = style
        model.scriptInit = scriptInit
        return model
    }
}
