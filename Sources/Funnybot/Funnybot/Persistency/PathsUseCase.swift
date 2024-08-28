//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation

protocol PathsUseCase {
    func videosFolder(for episode: Episode) -> URL
    func charactersFolder(for series: Series) -> URL
    func charactersFolder(for character: SeriesCharacter) -> URL
}

class PathsUseCaseImpl: PathsUseCase {
    @Inject private var configStorage: ConfigStorageService
    
    var config: Config {
        configStorage.current
    }
    
    func videosFolder(for episode: Episode) -> URL {
        let episodeFolder = "\(episode.number)_\(episode.title.urlSafe())"
        return config.videosFolder
            .appendingPathComponent(episodeFolder, conformingTo: .folder)
    }
    
    func charactersFolder(for series: Series) -> URL {
        charactersFolder(seriesTitle: series.title)
    }
    
    func charactersFolder(for character: SeriesCharacter) -> URL {
        if let series = character.series {
            charactersFolder(for: series)
        } else {
            charactersFolder(seriesTitle: "unknown")
        }
    }
    
    private func charactersFolder(seriesTitle: String) -> URL {
        config.videosFolder
            .appendingPathComponent("..", conformingTo: .folder)
            .appendingPathComponent(seriesTitle, conformingTo: .folder)
    }
}
