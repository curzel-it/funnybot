//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import SwiftUI

extension NavigationDestination {
    func history() -> [NavigationDestination] {
        var items: [NavigationDestination] = [self]
        if let parent {
            items.append(contentsOf: parent.history())
        }
        return items
    }
    
    var parent: NavigationDestination? {
        switch self {
        case .home: nil
        case .settings: .home
        case .config: .settings
        case .series: .home
        case .characters(let series): .series(series: series)
        case .character(let character): character.series.let { .characters(series: $0) }
        case .bodyBuilder(let character): .character(character: character)
        case .episode(let episode): episode.series.let { .series(series: $0) }
        case .episodeGroupChat(let episode): .episode(episode: episode)
        case .rendering(let episode): .episode(episode: episode)
        case .dubber(let episode): .episode(episode: episode)
        }
    }
}
