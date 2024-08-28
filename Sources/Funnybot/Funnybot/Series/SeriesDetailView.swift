//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Combine
import Foundation
import Schwifty
import SwiftUI
import SwiftData

struct SeriesDetailView: View {
    @EnvironmentObject var tab: TabViewModel
    
    @StateObject private var viewModel: SeriesDetailViewModel
    
    private var disposables = Set<AnyCancellable>()
    
    init(series: Series) {
        let vm = SeriesDetailViewModel(series: series)
        _viewModel = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: .lg) {
                HStack(spacing: .md) {
                    Text(viewModel.title).pageTitleFont()
                    
                    Button(viewModel.charactersTitle) {
                        viewModel.seeCharacters()
                    }
                    Spacer()
                    
                    Button("Delete") {
                        viewModel.delete()
                    }
                }
                VStack(spacing: .md) {
                    FormField(title: "Title", value: $viewModel.title)
                    FormTextEditor(title: "About", value: $viewModel.about)
                    FormTextEditor(title: "Script Init", value: $viewModel.scriptInit, initiallyCollapsed: true)
                }
                if viewModel.canShowEpisodes {
                    SeriesEpisodesView(series: viewModel.series)
                }
            }
            .padding(.horizontal, .md)
        }
        .onAppear { viewModel.tab = tab }
        .onDisappear { viewModel.onDisappear() }
        .environmentObject(viewModel)
    }
}
