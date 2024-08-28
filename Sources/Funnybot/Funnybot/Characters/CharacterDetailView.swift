//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation
import Schwifty
import SwiftUI

struct CharacterDetailView: View {
    @EnvironmentObject var tab: TabViewModel
    @StateObject var viewModel: CharacterDetailViewModel
    
    init(character: SeriesCharacter) {
        let vm = CharacterDetailViewModel(for: character)
        _viewModel = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: .md) {
                HStack(spacing: .md) {
                    Text(viewModel.title).pageTitleFont()
                    Spacer()
                    
                    Button("Delete") {
                        viewModel.delete()
                    }
                }
                VStack(spacing: .lg) {
                    VStack(spacing: .md) {
                        Text("Basic Info").sectionTitle()
                        FormField(title: "Name", value: $viewModel.name)
                        FormField(title: "Voice", value: $viewModel.voice)
                        FormField(title: "Quick Voice", value: $viewModel.quickVoice)
                        FormField(title: "Volume", value: $viewModel.volume)
                        FormPicker(title: "Voice Model", value: $viewModel.customVoiceModel, options: ElevenLabsApiModel.allCases)
                        FormSwitch(title: "Main Cast", value: $viewModel.isMainCast)
                        FormTextEditor(title: "About", value: $viewModel.about)
                    }
                    VStack(spacing: .md) {
                        Text("Rendering").sectionTitle()
                        FormField(title: "Path", value: $viewModel.path)
                        FormField(title: "Size", value: $viewModel.size)
                        FormSwitch(title: "Mouth Overlay", value: $viewModel.usesMouthOverlay)
                        FormSwitch(title: "Eyes Overlay", value: $viewModel.usesEyesOverlay)
                        FormTextEditor(title: "After-Talk Script", value: $viewModel.afterTalkScript)
                        
                        Button("Body Builder") {
                            viewModel.showBodyBuilder()
                        }
                        .positioned(.leading)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, .md)
            .padding(.bottom, .md)
        }
        .onAppear { viewModel.tab = tab }
        .onDisappear { viewModel.onDisappear() }
    }
}

extension ElevenLabsApiModel: FormPickerOption {}
