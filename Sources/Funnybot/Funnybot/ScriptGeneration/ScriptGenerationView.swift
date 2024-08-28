//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation
import SwiftUI

struct ScriptGenerationView: View {
    @StateObject var viewModel: ScriptGenerationViewModel
    
    init(episode: Episode) {
        let vm = ScriptGenerationViewModel(episode: episode)
        _viewModel = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        VStack(spacing: .md) {
            Text(viewModel.title).pageTitle()
            DSTextView(value: $viewModel.transcript)
            
            HStack(spacing: .md) {
                DSTextView(value: $viewModel.prompt)
                    .frame(height: 50)
                
                if viewModel.autoGenerationEnabled {
                    Button("Stop") {
                        viewModel.stopGenerating()
                    }
                } else {
                    Button("Go wild babe") {
                        viewModel.goWild()
                    }
                    Button("Copy") {
                        viewModel.copyScript()
                    }
                    Button("Format") {
                        viewModel.format()
                    }
                    Button("Add Sound Effects") {
                        viewModel.addSoundEffects()
                    }
                    Button("Add CTAs") {
                        viewModel.addCallToActions()
                    }
                }
            }
        }
        .padding(.horizontal, .md)
        .padding(.bottom, .md)
    }
}
