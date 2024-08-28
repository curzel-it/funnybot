//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation
import Schwifty
import SwiftUI

struct DubberView: View {
    @EnvironmentObject var tab: TabViewModel
    @StateObject var viewModel: DubberViewModel
    
    init(episode: Episode) {
        let vm = DubberViewModel(episode: episode)
        _viewModel = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: .md) {
                VStack(spacing: .sm) {
                    HStack(spacing: .md) {
                        Text("Dubber").pageTitleFont()
                        
                        Button("Generate Dubs") {
                            viewModel.generateDubs()
                        }
                        Button("List Voices") {
                            viewModel.listVoices()
                        }
                        Spacer()
                    }
                    if let progress = viewModel.progress {
                        ProgressView(value: progress)
                            .progressViewStyle(.linear)
                    }
                }
                DSList(viewModel.dubs) {
                    DialogLineView(line: $0)
                }
                Spacer()
            }
            .padding(.horizontal, .md)
            .padding(.bottom, .md)
        }
        .onAppear { viewModel.tab = tab }
        .environmentObject(viewModel)
    }
}
