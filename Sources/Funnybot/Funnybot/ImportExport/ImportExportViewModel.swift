//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import SwiftUI
import Schwifty

class ImportExportViewModel: ObservableObject {
    @Inject private var storage: ConfigStorageService
    @Inject private var filePicker: FilePickerUseCase
    @Inject private var exporter: ExportUseCase
    @Inject private var importer: ImportUseCase
    @Inject private var cleaner: CleanerUseCase
    @Inject private var app: AppViewModel
        
    private let tag = "ImportExportViewModel"
    
    @MainActor
    func runExport() {
        guard let selectedUrl = filePicker.openSelection(for: .filesAndFolders) else { return }
        let fileUrl = selectedUrl.isExistingFolder() ? selectedUrl.appendingPathComponent(exporter.nextFileName(), conformingTo: .json) : selectedUrl
        
        app.message(text: "Exporting...")
        do {
            let data = try exporter.export()
            try data.write(to: fileUrl)
        } catch {
            Logger.debug(tag, "Error during export: \(error)")
        }
        app.hideMessages()
    }
    
    @MainActor
    func runImport() {
        guard let url = filePicker.openSelection(for: .files) else { return }
        guard !url.isExistingFolder() else { return }
        
        app.message(text: "Importing...")
        do {
            let data = try Data(contentsOf: url)
            try cleaner.deleteAll()
            try importer.import(data: data)
            app.hideMessages()
        } catch {
            app.hideMessages()
            Logger.debug(tag, "Error during import: \(error)")
        }
    }
    
    @MainActor
    func runWipe() {
        app.message(text: "Deleting everything...")
        do {
            try cleaner.deleteAll()
            storage.reload()
            app.hideMessages()
        } catch {
            app.hideMessages()
            Logger.debug(tag, "Error during wipe: \(error)")
        }
    }
}
