//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Combine
import AskGpt
import Schwifty
import SwiftUI
import Swinject

struct SettingsView: View {
    @EnvironmentObject var tab: TabViewModel
    @State private var viewModel = SettingsViewModel()
    
    var body: some View {
        VStack(spacing: .lg) {
            Text("Settings").pageTitle()
            ImportExportView()
            AvailableProfiles()
            ThirdPartySettingsView()
            Spacer()
        }
        .padding(.horizontal, .md)
        .onAppear { viewModel.onAppear(tab: tab) }
        .environmentObject(viewModel)
        .environment(\.useLongLabelsForFormFields, true)
    }
}

private struct AvailableProfiles: View {
    @EnvironmentObject var tab: TabViewModel
    @EnvironmentObject var viewModel: SettingsViewModel
    
    var body: some View {
        VStack(spacing: .md) {
            VStack(spacing: .sm) {
                Text("Profiles").sectionTitle()
                
                ForEach(viewModel.configs) { config in
                    HStack(spacing: .md) {
                        Text(config.name)
                            .textAlign(.leading)
                            .lineLimit(1)
                            .frame(maxWidth: 200)
                        
                        HStack(spacing: .sm) {
                            Button("Edit") {
                                tab.navigate(to: .config(config: config))
                            }
                            if viewModel.selectedConfig != config {
                                Button("Select") {
                                    viewModel.setCurrent(config: config)
                                }
                            }
                        }
                        Spacer()
                    }
                }
            }
            Button("New Profile") {
                viewModel.newProfile()
            }
            .positioned(.leading)
        }
    }
}
