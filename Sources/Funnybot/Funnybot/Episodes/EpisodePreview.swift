//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation
import SwiftUI
import SwiftData
import Schwifty

struct EpisodePreview: View {
    @EnvironmentObject var viewModel: TabViewModel
    
    let episode: Episode
    
    var body: some View {
        VStack(spacing: .md) {
            Text(episode.title).cardTitle()
            
            Button("Select") {
                viewModel.navigate(to: episode)
            }
        }
        .card()
    }
}

struct EpisodeListItem: View {
    @EnvironmentObject var viewModel: TabViewModel
    
    let episode: Episode
    
    var body: some View {
        Text("\(episode.number). \(episode.title)")
            .font(.headline)
            .onTapGesture {
                viewModel.navigate(to: episode)
            }
    }
}

