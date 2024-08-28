import SwiftUI
import Foundation

#if os(macOS)
extension NSImage {
    func draw(at position: CGPoint, customSize: CGSize?, interpolation: NSImageInterpolation) {
        let rect = CGRect(origin: position, size: customSize ?? size)
        if rect.isEmpty { return }
        let resizedImage = resized(to: rect.size, interpolation: interpolation)
        resizedImage.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1.0)
    }
    
    func draw(in frame: CGRect, within bounds: CGRect, interpolation: NSImageInterpolation) {
        // Calculate the intersection of the frame with the bounds
        let intersectionRect = frame.intersection(bounds)

        // Check if there is an intersection
        if !intersectionRect.isEmpty {
            // Calculate the part of the image to be drawn
            let sourceRect = CGRect(x: -frame.origin.x + bounds.origin.x,
                                    y: -frame.origin.y + bounds.origin.y,
                                    width: frame.size.width,
                                    height: frame.size.height)

            // Resize the image to fit the frame size
            let resizedImage = self.resized(to: frame.size, interpolation: interpolation)

            // Draw the portion of the image that intersects with the bounds
            resizedImage.draw(in: intersectionRect, from: sourceRect, operation: .sourceOver, fraction: 1.0)
        }
    }
}
#endif
