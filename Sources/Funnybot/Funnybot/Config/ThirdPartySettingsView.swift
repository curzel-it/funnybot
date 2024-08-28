//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation
import Schwifty
import SwiftUI
import AskGpt

struct ThirdPartySettingsView: View {
    @StateObject var viewModel = ThirdPartySettingsViewModel()
    
    var body: some View {
        VStack(spacing: .sm) {
            Text("Third-Party Services").sectionTitle()
            FormPicker(title: "Chat Model", value: $viewModel.chatModel, options: AskGptModel.allCases)
            FormPicker(title: "Working Model", value: $viewModel.workingModel, options: AskGptModel.allCases)
            FormField(title: "OpenAI API Key", value: $viewModel.openAiKey)
            FormField(title: "OpenRouter API Key", value: $viewModel.openRouterKey)
            FormField(title: "ElevenLabs API Key", value: $viewModel.elevenLabsKey)
            FormField(title: "Mistral API Key", value: $viewModel.mistralKey)
        }
        .onWindow { viewModel.window = $0 }
    }
}
