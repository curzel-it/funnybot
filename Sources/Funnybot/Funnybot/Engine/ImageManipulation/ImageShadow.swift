import SwiftUI
import Foundation

#if os(macOS)
extension NSImage {
    func applying(shadow: NSShadow?) -> NSImage {
        guard let shadow else { return self }
        guard let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return self }
        let sizeWithShadow = NSSize(
            width: size.width + 2*(abs(shadow.shadowOffset.width) + shadow.shadowBlurRadius),
            height: size.height + 2*(abs(shadow.shadowOffset.height) + shadow.shadowBlurRadius)
        )
        let shadowedImage = NSImage(size: sizeWithShadow)
        shadowedImage.lockFocus()
        let context = NSGraphicsContext.current?.cgContext
        context?.setShadow(
            offset: shadow.shadowOffset,
            blur: shadow.shadowBlurRadius,
            color: (shadow.shadowColor)?.cgColor
        )
        let imageOrigin = NSPoint(
            x: abs(shadow.shadowOffset.width) + shadow.shadowBlurRadius - (shadow.shadowOffset.width < 0 ? shadow.shadowOffset.width : 0),
            y: abs(shadow.shadowOffset.height) + shadow.shadowBlurRadius - (shadow.shadowOffset.height < 0 ? shadow.shadowOffset.height : 0)
        )
        context?.draw(cgImage, in: CGRect(origin: imageOrigin, size: size))
        shadowedImage.unlockFocus()
        return shadowedImage
    }
}
#endif
