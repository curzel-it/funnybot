//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation
import Schwifty
import SwiftUI
import SwiftData

enum NavigationDestination: Equatable {
    case home
    case settings
    case config(config: Config)
    case series(series: Series)
    case characters(series: Series)
    case character(character: SeriesCharacter)
    case bodyBuilder(character: SeriesCharacter)
    case episode(episode: Episode)
    case episodeGroupChat(episode: Episode)
    case rendering(episode: Episode)
    case dubber(episode: Episode)
}

extension NavigationDestination: CustomStringConvertible {
    var description: String {
        switch self {
        case .home: "home"
        case .settings: "settings"
        case .config(let config): "config:\(config.id)"
        case .series(let series): "series:\(series.id)"
        case .characters(let series): "characters:\(series.id)"
        case .character(let character): "character:\(character.id)"
        case .bodyBuilder(let character): "bodyBuilder:\(character.id)"
        case .episode(let episode): "episode:\(episode.id)"
        case .episodeGroupChat(let episode): "episodeGroupChat:\(episode.id)"
        case .rendering(let episode): "rendering:\(episode.id)"
        case .dubber(let episode): "dubber:\(episode.id)"
        }
    }
}

extension NavigationDestination {
    var title: String {
        switch self {
        case .home: "Dashboard"
        case .settings: "Settings"
        case .config(let config): config.name
        case .series(let series): series.title
        case .characters: "Characters"
        case .character(let character): character.name
        case .bodyBuilder: "Body Builder"
        case .episode(let episode): episode.title
        case .episodeGroupChat: "Group Chat"
        case .rendering: "Rendering"
        case .dubber: "Dubbing"
        }
    }
}

extension NavigationDestination: Identifiable {
    var id: String {
        description
    }
}
