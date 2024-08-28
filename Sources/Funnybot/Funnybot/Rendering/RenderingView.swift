//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation
import Schwifty
import SwiftUI

struct RenderingView: View {
    @StateObject var viewModel: RenderingViewModel
    
    init(episode: Episode) {
        let vm = RenderingViewModel.instances[episode.id] ?? RenderingViewModel(episode: episode)
        _viewModel = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: .lg) {
                HStack(spacing: .md) {
                    Text("Rendering").pageTitleFont()
                    Spacer()
                }
                if viewModel.message != nil || viewModel.progress != nil {
                    VStack(spacing: .md) {
                        if let message = viewModel.message {
                            Text(message).textAlign(.leading).cardTitleFont()
                        }
                        if let progress = viewModel.progress {
                            ProgressView(value: progress)
                                .progressViewStyle(.linear)
                        }
                    }
                } else {
                    VStack(spacing: .md) {
                        Button("Open Videos Folder") {
                            viewModel.openVideosFolder()
                        }
                        .positioned(.leading)
                        
                        Button("Delete all Videos") {
                            viewModel.deleteAllVideos()
                        }
                        .positioned(.leading)
                        
                        ForEach(viewModel.configurations) { config in
                            Button("Render as \(config.name)") {
                                Task {
                                    await viewModel.start(with: config)
                                }
                            }
                            .positioned(.leading)
                        }
                        
                        Button("Generate Subtitles") {
                            viewModel.generateSubtitles()
                        }
                        .positioned(.leading)
                        
                        Spacer()
                    }
                    .positioned(.leading)
                }
            }
            .padding(.horizontal, .md)
        }
        .environmentObject(viewModel)
        .onAppear { viewModel.onAppear() }
    }
}
