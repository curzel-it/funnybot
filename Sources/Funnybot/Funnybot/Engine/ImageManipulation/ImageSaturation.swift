import SwiftUI

#if os(macOS)
extension NSImage {
    func saturated(by saturation: CGFloat?) -> NSImage {
        guard let saturation,
              let tiffData = tiffRepresentation,
              let bitmapImageRep = NSBitmapImageRep(data: tiffData),
              let ciImage = CIImage(bitmapImageRep: bitmapImageRep),
              let filter = CIFilter(name: "CIColorControls") else {
            return self
        }
        
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(saturation, forKey: kCIInputSaturationKey)
        
        guard let outputImage = filter.outputImage else {
            return self
        }
        
        let rep = NSCIImageRep(ciImage: outputImage)
        let nsImage = NSImage(size: rep.size)
        nsImage.addRepresentation(rep)
        
        return nsImage
    }
}
#else
extension UIImage {
    func saturated(by saturation: CGFloat?) -> UIImage {
        guard let ciImage, let filter = CIFilter(name: "CIColorControls") else {
            return self
        }
        
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(saturation, forKey: kCIInputSaturationKey)
        
        guard let outputImage = filter.outputImage else {
            return self
        }        
        return UIImage(ciImage: outputImage)
    }
}
#endif
