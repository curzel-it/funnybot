//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation
import Combine
import SwiftData

protocol LastOpenTabsUseCase {}

enum LastOpenTabsError: Error {
    case keyNotFound
    case entityNotFound
}

class LastOpenTabsUseCaseImpl: LastOpenTabsUseCase {
    @Inject private var broker: RuntimeEventsBroker
    @Inject private var appViewModel: AppViewModel
    @Inject private var modelContainer: ModelContainer
    
    private var latestGroups: Groups?
    private let tag = "LastOpenTabsUseCaseImpl"
    private let kLastOpenTabs = "kLastOpenTabs"
    private var disposables = Set<AnyCancellable>()
    
    init() {
        DispatchQueue.main.async { [weak self] in
            self?.bindRestore()
            self?.bindSave()
        }
    }
    
    private func bindRestore() {
        broker.events()
            .filter { $0 == .windowAttached(window: nil) }
            .sink { [weak self] _ in self?.restore() }
            .store(in: &disposables)
    }
    
    private func bindSave() {
        Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.save() }
            .store(in: &disposables)
    }
    
    private func save() {
        Task { @MainActor in
            let groups = Groups(from: appViewModel.tabsContainers)
            guard latestGroups != groups else { return }
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(groups)
            UserDefaults.standard.set(data, forKey: kLastOpenTabs)
        }
    }
    
    private func restore() {
        Task { @MainActor in
            let data = try UserDefaults.standard.data(forKey: kLastOpenTabs).unwrap()
            let groups = try JSONDecoder().decode(Groups.self, from: data)
            let containers = tabsContainers(from: groups)
            guard !containers.isEmpty else { return }
            appViewModel.loadTabsContainers(containers)
        }
    }
    
    @MainActor
    private func tabsContainers(from groups: Groups) -> [TabsContainerViewModel] {
        groups.groups.compactMap { tabsContainer(from: $0) }
    }
    
    @MainActor
    private func tabsContainer(from group: Group) -> TabsContainerViewModel? {
        let container = TabsContainerViewModel()
        container.tabs = group.tabs.compactMap { try? tab(from: $0) }
        return container.tabs.isEmpty ? nil : container
    }
    
    @MainActor
    private func tab(from tab: Tab) throws -> TabViewModel {
        let destination = try destination(from: tab.value)
        let tab = TabViewModel()
        tab.navigate(to: destination)
        return tab
    }
    
    @MainActor
    private func destination(from value: String) throws -> NavigationDestination {
        let (key, uuid) = destinationValues(from: value)
        return switch key {
        case "home": .home
        case "settings": .settings
        case "config": .config(config: try entity(uuid))
        case "series": .series(series: try entity(uuid))
        case "characters": .characters(series: try entity(uuid))
        case "character": .character(character: try entity(uuid))
        case "bodyBuilder": .bodyBuilder(character: try entity(uuid))
        case "episode": .episode(episode: try entity(uuid))
        case "episodeGroupChat": .episodeGroupChat(episode: try entity(uuid))
        case "dubber": .dubber(episode: try entity(uuid))
        case "rendering": .rendering(episode: try entity(uuid))
        default: throw LastOpenTabsError.keyNotFound
        }
    }
    
    @MainActor
    private func entity<T: IdentifiableRecord>(_ id: UUID) throws -> T {
        do {
            let descriptor = FetchDescriptor<T>()
            let records = try modelContainer.mainContext.fetch(descriptor)
            let record = records.first { $0.id == id }
            return try record.unwrap()
        } catch {
            throw LastOpenTabsError.entityNotFound
        }
    }
    
    func destinationValues(from value: String) -> (String, UUID) {
        let tokens = value.components(separatedBy: ":")
        let uuid = UUID(uuidString: tokens.last ?? "") ?? UUID()
        return (tokens.first ?? "", uuid)
    }
}

private struct Groups: Codable, Equatable {
    let groups: [Group]
    
    init(from viewModels: [TabsContainerViewModel]) {
        groups = viewModels.map { Group(from: $0) }
    }
}

private struct Group: Codable, Equatable {
    let tabs: [Tab]
    
    init(from viewModel: TabsContainerViewModel) {
        tabs = viewModel.tabs.map { Tab(from: $0) }
    }
}

private struct Tab: Codable, Equatable {
    let value: String
    
    init(from viewModel: TabViewModel) {
        value = viewModel.current.description
    }
}
