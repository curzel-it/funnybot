//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation
import SwiftUI

class TabsContainerViewModel: ObservableObject, Identifiable {
    let id = UUID()
    
    @Published var index: Int = 0
    @Published var tabs: [TabViewModel] = []
    @Published var selectedTab: UUID = UUID()
    
    @Inject private var appViewModel: AppViewModel
    
    var title: String {
        id.uuidString
    }
    
    var canBeClosed: Bool {
        appViewModel.tabsContainers.count > 1
    }
    
    @MainActor
    init() {
        reset()
    }
    
    @MainActor
    func reset() {
        tabs = []
        newTab()
    }
    
    func leadingPadding(forHeaderOf tab: TabViewModel) -> CGFloat {
        let index = index(of: tab)
        let selectedIndex = indexOfSelectedTab()        
        if index == 0 { return 0 }
        if index == selectedIndex + 1 { return 0 }
        return DesignSystem.Tabs.headersSpacing
    }
    
    func isSelected(_ tab: TabViewModel) -> Bool {
        selectedTab == tab.id
    }
    
    @MainActor
    func select(_ tab: TabViewModel) {
        selectedTab = tab.id
    }
    
    @MainActor
    @discardableResult
    func newTab() -> TabViewModel {
        let newTab = TabViewModel()
        let current = tabs.first { $0.id == selectedTab }?.current
        newTab.navigate(to: current ?? .home)
        tabs.append(newTab)
        select(newTab)
        return newTab
    }
    
    @MainActor
    func close() {
        appViewModel.close(self)
    }
    
    @MainActor
    func close(_ oldTab: TabViewModel) {
        tabs.removeAll { $0.id == oldTab.id }
        if tabs.isEmpty {
            close()
        } else if isSelected(oldTab), let next = tabs.first {
            select(next)
        }
    }
    
    func index(of tab: TabViewModel) -> Int {
        tabs.firstIndex { $0.id == tab.id } ?? 0
    }
    
    private func indexOfSelectedTab() -> Int {
        tabs.firstIndex { $0.id == selectedTab } ?? 0
    }
}
