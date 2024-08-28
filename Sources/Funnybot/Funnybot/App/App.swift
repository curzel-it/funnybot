//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import SwiftUI
import SwiftData

@main
struct FunnybotApp: App {
    @Inject private var broker: RuntimeEventsBroker
    @Inject private var modelContainer: ModelContainer
    @Inject private var windowManager: WindowManager
    
    @StateObject var viewModel = AppViewModel()
    
    // swiftlint:disable:next weak_delegate
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        Dependencies.setup()
    }
    
    var body: some Scene {
        WindowGroup {
            HStack(spacing: 2) {
                ForEach(viewModel.tabsContainers) {
                    TabsContainer(viewModel: $0)
                }
            }
            .background(Color.secondaryBackground)
            .onWindow { broker.send(.windowAttached(window: $0)) }
            .preferredColorScheme(.dark)
            .showsMessages()
            .environmentObject(viewModel)
        }
        .withCustomizedMenuBar()
        .modelContainer(modelContainer)
    }
}
