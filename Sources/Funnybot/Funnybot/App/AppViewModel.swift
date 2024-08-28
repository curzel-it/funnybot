//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import SwiftUI

class AppViewModel: ObservableObject {
    static var shared: AppViewModel!
    
    @Published var isShowingMessage: Bool = false
    
    @Published var message: AppMessage? {
        didSet {
            isShowingMessage = message != nil
        }
    }
    
    @Published private(set) var tabsContainers: [TabsContainerViewModel] = [] {
        didSet {
            reloadGroupsIndeces()
        }
    }
    
    @MainActor
    init() {
        AppViewModel.shared = self
        reset()
    }
    
    func closeActionTitle(for tabs: TabsContainerViewModel) -> String {
        let index = index(of: tabs) ?? 0
        return "Close Tabs Group #\(index+1)"
    }
    
    func index(of tabs: TabsContainerViewModel) -> Int? {
        tabsContainers.firstIndex { $0.id == tabs.id }
    }
    
    @MainActor
    func loadTabsContainers(_ tabs: [TabsContainerViewModel]) {
        tabsContainers = tabs
        tabsContainers.forEach { container in
            if let anyTab = container.tabs.first {
                container.select(anyTab)
            }
        }
    }
    
    @MainActor
    func close(_ tabs: TabsContainerViewModel) {
        tabsContainers.removeAll { $0.id == tabs.id }
        if tabsContainers.isEmpty {
            newTabsContainer()
        }
    }
    
    @MainActor
    @discardableResult
    func newTabsContainer() -> TabsContainerViewModel{
        let lastContainer = tabsContainers.last
        let new = TabsContainerViewModel()
        tabsContainers.append(new)
                
        let currentTab = lastContainer?.tabs.first { $0.id == lastContainer?.selectedTab }
        guard let currentTab else { return new }
        new.tabs.first?.navigate(to: currentTab.current)
        return new
    }
    
    @MainActor
    func showSettings() {
        guard let container = tabsContainers.first else { return }
        let tab = container.newTab()
        tab.navigate(to: .settings)
    }
    
    func message(text: String?) {
        DispatchQueue.main.async { [weak self] in
            withAnimation {
                if let text {
                    self?.message = AppMessage(text: text)
                } else {
                    self?.message = nil
                }
            }
        }
    }
    
    func hideMessages() {
        DispatchQueue.main.async { [weak self] in
            withAnimation {
                self?.message = nil
            }
        }
    }
    
    func copyMessage() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(message?.text ?? "", forType: .string)
    }
    
    func openAbout() {
        let urlString = "https://github.com/curzel-it/funnybot"
        URL(string: urlString)?.visit()
    }
    
    func openDocs() {
        let urlString = "https://github.com/curzel-it/funnybot"
        URL(string: urlString)?.visit()
    }
    
    func openIssue() {
        let urlString = "https://github.com/curzel-it/funnybot/issues/new"
        URL(string: urlString)?.visit()
    }
    
    @MainActor
    private func reset() {
        tabsContainers = []
        newTabsContainer()
    }
    
    private func reloadGroupsIndeces() {
        if tabsContainers.count <= 1 {
            tabsContainers
                .enumerated()
                .forEach { (index, tabs) in tabs.index = index }
        } else {
            tabsContainers
                .enumerated()
                .forEach { (index, tabs) in tabs.index = index + 1 }
        }
    }
}
