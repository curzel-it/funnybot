//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

#if os(macOS)
import Foundation
import Cocoa
import Combine
import Schwifty

class FilePickerUseCaseImpl: FilePickerUseCase {
    @Inject private var broker: RuntimeEventsBroker
    
    private let bookmarksKey = "folderBookmarks"
    private let tag = "FilePickerUseCase"
    private var disposables = Set<AnyCancellable>()
    
    init() {
        DispatchQueue.main.async { [weak self] in self?.setup() }
    }
    
    private func setup() {
        restoreFolderAccess()
        
        broker.events()
            .filter { $0 == .appWillTerminate }
            .sink { [weak self] _ in self?.stopAccessingFolders() }
            .store(in: &disposables)
    }
    
    func openSelection(title: String?, for selectionType: FilePickerSelectionType) -> URL? {
        let openPanel = NSOpenPanel()
        openPanel.title = title ?? selectionType.defaultTitle
        openPanel.showsResizeIndicator = true
        openPanel.showsHiddenFiles = false
        openPanel.canChooseFiles = selectionType.canChooseFiles
        openPanel.canChooseDirectories = selectionType.canChooseFolders
        openPanel.allowsMultipleSelection = false
        
        if openPanel.runModal() == .OK, let selectedUrl = openPanel.urls.first {
            if selectionType == .folders || selectionType == .filesAndFolders {
                saveFolderPermission(url: selectedUrl)
            }
            return selectedUrl
        }
        return nil
    }
    
    private func saveFolderPermission(url: URL) {
        do {
            let bookmarkData = try url.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            UserDefaults.standard.set(folderPermissions() + [bookmarkData], forKey: bookmarksKey)
        } catch {
            Logger.debug(tag, "Error creating permission bookmark: \(error)")
        }
    }
    
    private func folderPermissions() -> [Data] {
        UserDefaults.standard.array(forKey: bookmarksKey) as? [Data] ?? []
    }
    
    private func restoreFolderAccess() {
        let bookmarksData = folderPermissions()
        guard !bookmarksData.isEmpty else { return }
        
        for item in bookmarksData {
            try? startAccessingFolder(item)
        }
    }
    
    private func stopAccessingFolders() {
        folderPermissions().forEach {
            try? stopAccessingFolder($0)
        }
    }
    
    private func url(withBookmarkData data: Data) throws -> URL {
        var isStale = false
        return try URL(
            resolvingBookmarkData: data,
            options: .withSecurityScope,
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        )
    }
    
    private func startAccessingFolder(_ data: Data) throws {
        let folderUrl = try url(withBookmarkData: data)
        _ = folderUrl.startAccessingSecurityScopedResource()
    }
    
    private func startAccessingFolder(_ folderUrl: URL) {
        _ = folderUrl.startAccessingSecurityScopedResource()
    }
    
    private func stopAccessingFolder(_ data: Data) throws {
        let folderUrl = try url(withBookmarkData: data)
        stopAccessingFolder(folderUrl)
    }
    
    private func stopAccessingFolder(_ folderUrl: URL) {
        folderUrl.stopAccessingSecurityScopedResource()
    }
}
#endif
