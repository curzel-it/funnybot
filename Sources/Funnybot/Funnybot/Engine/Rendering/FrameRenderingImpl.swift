//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import SwiftUI
import Foundation
import Schwifty

class FrameRenderingImpl: FrameRendering {
    @Inject var assets: AssetsProvider
    @Inject var shadowing: ShadowingUseCase
    
    var itemsCache: [String: NSImage] = [:]
    let tag = "FrameRenderingImpl"
    let cacheQueue = DispatchQueue(label: "FrameRenderingImpl", qos: .userInitiated)
    
    func render(
        frame: RenderableFrame,
        resolution: CGSize,
        interpolation: NSImageInterpolation
    ) -> NSImage {
        let canvas = NSImage(size: resolution)
        canvas.lockFocus()
        
        for item in frame.items {
            autoreleasepool {
                let image = render(item: item, interpolation: interpolation)
                image.draw(at: item.frame.origin, customSize: item.frame.size, interpolation: interpolation)
            }
        }
        canvas.unlockFocus()
        return canvas
    }
        
    func render(
        frames: [RenderableFrame],
        resolution: CGSize,
        interpolation: NSImageInterpolation,
        onFrameRendered: @escaping () -> Void
    ) -> [NSImage] {
        Logger.debug(tag, "Rendering \(frames.count) frames")
        return frames.map {
            onFrameRendered()
            return render(frame: $0, resolution: resolution, interpolation: interpolation)
        }
    }
    
    private func render(item: RenderableItem, interpolation: NSImageInterpolation) -> NSImage {
        if let image = cachedItem(for: item) {
            return image.image(withAlpha: item.alpha)
        }
        guard var canvas = assets.image(sprite: item.sprite) else { return NSImage() }
        
        if let rotation = item.rotation {
            canvas = canvas
                .rotated(byDegrees: rotation.zAngle)
                .flipped(
                    horizontally: rotation.isFlippedHorizontally,
                    vertically: rotation.isFlippedVertically,
                    interpolation: interpolation
                )
        }
        
        let shadow = shadowing.shadow(for: item.entityId)
        canvas = canvas.applying(shadow: shadow)
        
        cache(image: canvas, for: item)
        return canvas.image(withAlpha: item.alpha)
    }
    
    private func cachedItem(for item: RenderableItem) -> NSImage? {
        cacheQueue.sync {
            itemsCache[itemCachingKey(for: item)]
        }
    }
    
    private func cache(image: NSImage, for item: RenderableItem) {
        cacheQueue.sync {
            itemsCache[itemCachingKey(for: item)] = image
        }
    }
    
    private func itemCachingKey(for item: RenderableItem) -> String {
        [
            item.sprite,
            item.frame.size.description,
            "\(item.rotation?.zAngle ?? 0)",
            "\(item.rotation?.isFlippedVertically ?? false)",
            "\(item.rotation?.isFlippedHorizontally ?? false)"
        ].joined(separator: "; ")
    }
}
