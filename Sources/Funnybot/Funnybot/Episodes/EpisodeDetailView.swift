//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation
import Schwifty
import SwiftUI
import SwiftData

struct EpisodeDetailView: View {
    @EnvironmentObject private var tab: TabViewModel
    @StateObject private var viewModel: EpisodeDetailViewModel
    
    init(episode: Episode) {
        let vm = EpisodeDetailViewModel(episode: episode)
        _viewModel = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: .lg) {
                HStack(spacing: .sm) {
                    Text(viewModel.title).pageTitleFont()
                    
                    if viewModel.canRender {
                        Button("Render") {
                            viewModel.showRendering()
                        }
                    }
                    Button("Generate") {
                        viewModel.generateScript()
                    }
                    Button("Dub") {
                        viewModel.showDubs()
                    }
                    
                    Spacer()
                    
                    Button("Delete") {
                        viewModel.delete()
                    }
                    
                    Button("Clone") {
                        viewModel.clone()
                    }
                }
                VStack(spacing: .md) {
                    FormField(title: "Title", value: $viewModel.title)
                    FormField(title: "Number", value: $viewModel.number)
                    FormTextEditor(title: "Concept", value: $viewModel.concept, initiallyCollapsed: true)
                    FormTextEditor(title: "Script", value: $viewModel.script, initiallyCollapsed: true)
                    Spacer(minLength: .zero)
                }
            }
            .padding(.horizontal, .md)
        }
        .onAppear { viewModel.tab = tab }
        .onDisappear { viewModel.onDisappear() }
    }
}
