//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation
import SwiftUI
import SwiftUI

protocol ViewScreenshotUseCase {
    func screenshot<V: View>(_ view: V, size: CGSize) async -> NSImage?
}

class ViewScreenshotUseCaseImpl: ViewScreenshotUseCase {
    func screenshot<V: View>(_ view: V, size: CGSize) async -> NSImage? {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                screenshot(view, size: size) { image in
                    continuation.resume(returning: image)
                }
            }
        }
    }
    
    @MainActor
    func screenshot<V: View>(_ view: V, size: CGSize, completion: @escaping (NSImage?) -> Void) {
        let hostingView = NSHostingView(rootView: view)
        let window = NSWindow(
            contentRect: CGRect(x: 0, y: size.height, width: size.width, height: size.height),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.contentView = hostingView
        window.show()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let image = NSImage(size: hostingView.bounds.size)
            image.lockFocus()
            if let context = NSGraphicsContext.current?.cgContext {
                context.translateBy(x: 0, y: size.height)
                context.scaleBy(x: 1.0, y: -1.0)
                hostingView.layer?.render(in: context)
            }
            image.unlockFocus()
            
            completion(image)
            
            window.close()
        }
    }
}
