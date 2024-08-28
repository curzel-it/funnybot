import SwiftUI
import Foundation

#if os(macOS)
extension NSImage {
    func resized(to newSize: CGSize, interpolation: NSImageInterpolation) -> NSImage {
        guard size != newSize else { return self }
        let newImage = NSImage(size: newSize)
        newImage.lockFocus()

        let srcRect = CGRect(origin: .zero, size: size)
        let destRect = CGRect(origin: .zero, size: newSize)

        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current?.imageInterpolation = interpolation
        draw(in: destRect, from: srcRect, operation: .copy, fraction: 1.0, respectFlipped: false, hints: nil)
        NSGraphicsContext.restoreGraphicsState()

        newImage.unlockFocus()
        return newImage
    }
}
#endif
