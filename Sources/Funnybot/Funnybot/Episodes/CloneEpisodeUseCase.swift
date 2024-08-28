//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation

protocol CloneEpisodeUseCase {
    func clone(_ episode: Episode) -> Episode
}

class CloneEpisodeUseCaseImpl: CloneEpisodeUseCase {
    func clone(_ episode: Episode) -> Episode {
        let clonedEpisode = Episode()
        clonedEpisode.series = episode.series
        clonedEpisode.title = episode.title + " (Clone)"
        clonedEpisode.number = episode.number
        clonedEpisode.concept = episode.concept
        clonedEpisode.script = episode.script
        return clonedEpisode
    }
}
