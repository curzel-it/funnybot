import SwiftUI

#if os(macOS)
extension NSImage {
    func cropped(bounds: CGRect) -> NSImage {
        if bounds.origin == .zero && bounds.size == size { return self }
        
        let sourceImageRect = CGRect(
            x: bounds.origin.x,
            y: size.height - bounds.origin.y - bounds.height,
            width: bounds.width,
            height: bounds.height
        )

        let newImage = NSImage(size: bounds.size)
        newImage.lockFocus()
        draw(at: .zero, from: sourceImageRect, operation: .copy, fraction: 1.0)
        newImage.unlockFocus()

        return newImage
    }
}
#else
extension UIImage {
    func cropped(to bounds: CGRect) -> UIImage? {
        guard let cgImage = self.cgImage,
              let croppedCGImage = cgImage.cropping(to: bounds) else {
            return nil
        }
        
        return UIImage(cgImage: croppedCGImage)
    }
}
/*
extension UIImage {
    func cropped(to bounds: CGRect) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        
        let contextImage: UIImage = UIImage(cgImage: cgImage)
        let contextSize: CGSize = contextImage.size
        
        // Calculate the cropping rect
        let posX: CGFloat = bounds.origin.x
        let posY: CGFloat = contextSize.height - bounds.origin.y - bounds.size.height
        let rect: CGRect = CGRect(x: posX, y: posY, width: bounds.size.width, height: bounds.size.height)

        // Perform the cropping
        guard let imageRef: CGImage = cgImage.cropping(to: rect) else { return nil }
        
        let croppedImage: UIImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        return croppedImage
    }
}*/
#endif
