//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation
import NotAGif
import SwiftUI

protocol ImageRepresentationsUseCase {
    func png(from image: ImageFrame?) -> Data?
}

class ImageRepresentationsUseCaseImpl: ImageRepresentationsUseCase {
#if os(macOS)
    func png(from image: ImageFrame?) -> Data? {
        guard let bitmap = bitmap(from: image),
              let data = bitmap.representation(using: .png, properties: [:]) else {
            return nil
        }
        return data
    }
    
    func bitmap(from image: NSImage?) -> NSBitmapImageRep? {
        guard let image,
              let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData) else {
            return nil
        }
        return bitmap
    }
#else
    func png(from image: ImageFrame?) -> Data? {
        image?.pngData()
    }
#endif
}
