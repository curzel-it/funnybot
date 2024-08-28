//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation
import Funnyscript

protocol IndexedDialogsUseCase {
    func indexedDialogs(for episode: Episode) async throws -> [IndexedDialogItem]
}

struct IndexedDialogItem {
    let index: Int
    let subject: String
    let dialog: String
}

extension Array where Element == IndexedDialogItem {
    func transcript() -> String {
        self
            .map { "\($0.index) \($0.subject): \"\($0.dialog)\"" }
            .joined(separator: "\n")
    }
}

class IndexedDialogsUseCaseImpl: IndexedDialogsUseCase {
    @Inject private var parser: Funnyscript.Parser
    
    func indexedDialogs(for episode: Episode) async throws -> [IndexedDialogItem] {
        try await parser
            .instructions(from: episode.fullScript)
            .compactMap { instruction in
                if case .talking(let dialog, _) = instruction.action {
                    (instruction.subject, dialog)
                } else {
                    nil
                }
            }
            .enumerated()
            .map { (index, dialog) in
                IndexedDialogItem(index: index, subject: dialog.0, dialog: dialog.1)
            }
    }
}
