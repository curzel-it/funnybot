//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation
import Schwifty

class DialogLineViewModel: ObservableObject {
    let line: DialogLine
        
    var speaker: String {
        line.speaker
    }
    
    var text: String {
        line.line
    }
    
    var canPlay: Bool {
        line.isDubbed
    }
    
    weak var dubber: DubberViewModel?
    
    @Inject private var app: AppViewModel
    @Inject private var filePicker: FilePickerUseCase
    @Inject private var audioConverter: AudioFormatConverterUseCase
    @Inject private var dubsStorage: DubsStorage
    
    private let tag = "DialogLineViewModel"

    init(line: DialogLine) {
        self.line = line
    }
    
    @MainActor
    func pickFile() {
        guard let sourceUrl = filePicker.openSelection(for: .files) else { return }
        
        Task {
            do {
                let data = try await audioConverter.convert(sourceUrl, toFormat: .m4a)
                try dubsStorage.save(speaker: line.speaker, line: line.line, data: data)
                await dubber?.reloadDubs()
            } catch {
                Logger.error(tag, "Error loading dub file: \(error)")
                app.message(text: "Error loading given file:\n\(error)")
            }
        }
    }
    
    @MainActor
    func dub() {
        dubber?.generateDub(for: line)
    }
}
