//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import SwiftUI

extension Scene {
    @MainActor
    func withCustomizedMenuBar() -> some Scene {
        @Inject var viewModel: AppViewModel
        
        return commands {
            CommandGroup(replacing: .newItem) {}
            
            CommandGroup(replacing: .appSettings) {
                Button("Settings") {
                    viewModel.showSettings()
                }
            }
            CommandGroup(replacing: .toolbar) {
                Button("New Group of Tabs") {
                    viewModel.newTabsContainer()
                }
                .keyboardShortcut(.init("t"), modifiers: [.command, .shift])
                
                if viewModel.tabsContainers.count > 1 {
                    Divider()
                    ForEach(viewModel.tabsContainers) { tabs in
                        Button(viewModel.closeActionTitle(for: tabs)) {
                            viewModel.close(tabs)
                        }
                    }
                }
            }
        }
    }
}
