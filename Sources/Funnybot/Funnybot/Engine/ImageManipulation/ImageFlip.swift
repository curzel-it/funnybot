import SwiftUI

#if os(macOS)
extension NSImage {
    func flipped(
        horizontally: Bool,
        vertically: Bool,
        interpolation: NSImageInterpolation
    ) -> NSImage {
        let flippedImage = NSImage(size: size)
        let rect = CGRect(size: size)
        flippedImage.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = interpolation

        let transform = NSAffineTransform()
        transform.translateX(
            by: horizontally ? size.width : 0,
            yBy: vertically ? size.height : 0
        )
        transform.scaleX(
            by: horizontally ? -1 : 1,
            yBy: vertically ? -1 : 1
        )
        transform.concat()

        draw(at: .zero, from: rect, operation: .sourceOver, fraction: 1)
        flippedImage.unlockFocus()
        return flippedImage
    }
}
#endif
