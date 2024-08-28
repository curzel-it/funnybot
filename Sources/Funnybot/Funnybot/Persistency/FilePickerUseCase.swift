//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import SwiftUI
import Combine
import Schwifty
import SwiftUI

protocol FilePickerUseCase {
    func openSelection(title: String?, for selectionType: FilePickerSelectionType) -> URL?
}

extension FilePickerUseCase {
    func openSelection(for selectionType: FilePickerSelectionType) -> URL? {
        openSelection(title: nil, for: selectionType)
    }
}

enum FilePickerSelectionType {
    case files
    case folders
    case filesAndFolders
}

extension FilePickerSelectionType {
    var defaultTitle: String {
        switch self {
        case .files: "Select a file"
        case .folders: "Select a folder"
        case .filesAndFolders: "Select a file or folder"
        }
    }
    
    var canChooseFiles: Bool {
        switch self {
        case .files, .filesAndFolders: true
        case .folders: false
        }
    }
    
    var canChooseFolders: Bool {
        switch self {
        case .folders, .filesAndFolders: true
        case .files: false
        }
    }
}
