import SwiftUI
import Foundation

#if os(macOS)
extension NSImage {
    func rotated(byDegrees degrees: CGFloat) -> NSImage {
        guard degrees != 0 else {
            return self
        }
        guard let cgImage = cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return self
        }
        
        let radians = degrees * .pi / 180
        let newWidth = abs(size.width * cos(radians)) + abs(size.height * sin(radians))
        let newHeight = abs(size.height * cos(radians)) + abs(size.width * sin(radians))
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        let rotatedImage = NSImage(size: newSize)
        rotatedImage.lockFocus()
        
        let context = NSGraphicsContext.current?.cgContext
        context?.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        
        let transform = NSAffineTransform()
        transform.rotate(byDegrees: degrees)
        transform.concat()
        
        let frame = CGRect(size: size).offset(x: -size.width / 2, y: -size.height / 2)
        context?.draw(cgImage, in: frame)
        rotatedImage.unlockFocus()
        return rotatedImage
    }
}
#endif
