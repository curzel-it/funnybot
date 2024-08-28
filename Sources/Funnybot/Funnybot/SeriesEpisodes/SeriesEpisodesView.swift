//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation
import SwiftUI
import SwiftData
import Schwifty

struct SeriesEpisodesView: View {
    @EnvironmentObject var tab: TabViewModel
    
    @StateObject var viewModel: SeriesEpisodesViewModel
    
    init(series: Series) {
        let vm = SeriesEpisodesViewModel(series: series)
        _viewModel = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        VStack(spacing: .md) {
            CollapsableHeader()
            
            if !viewModel.collapsed {
                DSList(viewModel.episodes, scrollable: false) {
                    EpisodeListItem(episode: $0)
                }
            }
        }
        .onAppear { viewModel.tab = tab }
        .environmentObject(viewModel)
    }
}

private struct CollapsableHeader: View {
    @EnvironmentObject var viewModel: SeriesEpisodesViewModel
    @EnvironmentObject var seriesViewModel: SeriesDetailViewModel
    
    var body: some View {
        HStack(spacing: .md) {
            HStack(spacing: .sm) {
                Button {
                    viewModel.toggleCollapse()
                } label: {
                    Image(systemName: viewModel.collapseIcon)
                        .foregroundColor(.label)
                        .frame(width: DesignSystem.Buttons.iconWidth)
                }
                Text(viewModel.title).sectionTitleFont()
            }
            Button("New Episode") {
                seriesViewModel.newEpisode()
            }
            Spacer()
        }
    }
}
