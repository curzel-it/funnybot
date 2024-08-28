//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import SwiftUI
import Foundation

protocol FrameRendering {
    func render(
        frame: RenderableFrame,
        resolution: CGSize,
        interpolation: NSImageInterpolation
    ) -> NSImage
    
    func render(
        frames: [RenderableFrame],
        resolution: CGSize,
        interpolation: NSImageInterpolation,
        onFrameRendered: @escaping () -> Void
    ) -> [NSImage]
}
