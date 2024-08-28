//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Combine
import Foundation
import SwiftUI
import AskGpt

class TabViewModel: ObservableObject, Identifiable {
    let id = UUID()
    
    @Published private(set) var current: NavigationDestination = .home
    @Published var navigationHistory: [NavigationDestination] = []
    
    private var disposables = Set<AnyCancellable>()
    
    init() {
        bindNavigationHistory()
    }
    
    private func bindNavigationHistory() {
        $current
            .receive(on: DispatchQueue.main)
            .sink { [weak self] destination in
                self?.navigationHistory = destination.history().reversed()
            }
            .store(in: &disposables)
    }
    
    func isSelected(_ item: NavigationDestination) -> Bool {
        item == current
    }
}

extension TabViewModel {
    func navigateBack() {
        Task { @MainActor in
            guard navigationHistory.count >= 2 else {
                current = .home
                return
            }
            let next = navigationHistory[navigationHistory.count-2]
            current = next
        }
    }
    
    func navigate(to item: NavigationDestination) {
        Task { @MainActor in
            current = item
        }
    }
    
    func navigate(to value: Series) {
        Task { @MainActor in
            current = .series(series: value)
        }
    }
    
    func navigate(to value: SeriesCharacter) {
        Task { @MainActor in
            current = .character(character: value)
        }
    }
    
    func navigate(to value: Episode) {
        Task { @MainActor in
            current = .episode(episode: value)
        }
    }
}
