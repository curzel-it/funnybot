//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation

#if !os(macOS)
class FilePickerUseCaseImpl: FilePickerUseCase {
    func openSelection(title: String?, for selectionType: FilePickerSelectionType) -> URL? {
        nil
    }
}
#endif
