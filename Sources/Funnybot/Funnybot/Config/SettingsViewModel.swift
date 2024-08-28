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

class SettingsViewModel: ObservableObject {
    @Inject private var storage: ConfigStorageService
    
    @Published var selectedConfig: Config
    @Published var configs: [Config] = []
    
    private weak var tab: TabViewModel?
    
    private var disposables = Set<AnyCancellable>()
    
    @MainActor
    init() {
        @Inject var storage: ConfigStorageService
        selectedConfig = storage.current
        reloadConfigs()
        bindSelectedConfig()
    }
    
    @MainActor
    func onAppear(tab: TabViewModel) {
        self.tab = tab
        reloadConfigs()
    }
    
    @MainActor
    func reloadConfigs() {
        configs = storage.all().sorted { $0.name < $1.name }
    }
    
    @MainActor
    func newProfile() {
        let newConfig = try? CodableConfig(from: selectedConfig).asModel()
        guard let newConfig else { return }
        newConfig.name = "New Profile"
        newConfig.id = UUID()
        tab?.navigate(to: .config(config: newConfig))
    }
    
    @MainActor
    func setCurrent(config: Config) {
        @Inject var storage: ConfigStorageService
        storage.setCurrent(config: config)
    }
    
    private func bindSelectedConfig() {
        $selectedConfig
            .sink { [weak self] config in
                Task { @MainActor [weak self] in
                    self?.setCurrent(config: config)
                }
            }
            .store(in: &disposables)
    }
}

extension Config: FormPickerOption {}
