import SwiftUI

#if os(macOS)
extension NSImage {
    func image(withAlpha alpha: CGFloat) -> NSImage {
        guard alpha != 1 else { return self }
        guard alpha != 0 else { return NSImage(size: size) }
        
        let bitmapRep = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: Int(size.width),
            pixelsHigh: Int(size.height),
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: NSColorSpaceName.calibratedRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        )
        guard let bitmapRep else { return self }
        
        bitmapRep.size = size
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmapRep)
        
        self.draw(at: .zero, from: .zero, operation: .sourceOver, fraction: alpha)
        NSGraphicsContext.restoreGraphicsState()
        
        let newImage = NSImage(size: size)
        newImage.addRepresentation(bitmapRep)
        return newImage
    }
}
#endif
