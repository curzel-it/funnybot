//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import SwiftUI
import Schwifty

extension NavigationDestination {
    func view() -> AnyView {
        switch self {
        case .home: Homepage().eraseToAnyView()
        case .settings: SettingsView().eraseToAnyView()
        case .config(let config): ConfigView(config: config).eraseToAnyView()
        case .series(let series): SeriesDetailView(series: series).eraseToAnyView()
        case .characters(let series): CharactersView(series: series).eraseToAnyView()
        case .character(let character): CharacterDetailView(character: character).eraseToAnyView()
        case .bodyBuilder(let character): BodyBuilderView(character: character).eraseToAnyView()
        case .episode(let episode): EpisodeDetailView(episode: episode).eraseToAnyView()
        case .episodeGroupChat(let episode): ScriptGenerationView(episode: episode).eraseToAnyView()
        case .rendering(let episode): RenderingView(episode: episode).eraseToAnyView()
        case .dubber(let episode): DubberView(episode: episode).eraseToAnyView()
        }
    }
}
