import SwiftUI
import Combine
import Foundation
import Schwifty
import Yage

protocol SceneRendering {
    func render(_: RenderableScene, onFrameRendered: @escaping () -> Void) async throws -> [URL]
}

typealias SceneRenderingUpdatesHandler = (SceneRenderingProgress) -> Void

struct SceneRenderingProgress: Identifiable {
    let id: UUID
    let frame: Int
    let totalFrames: Int
}

enum SceneRenderingError: Error {
    case cancelled
    case generic(error: Error)
}

struct EntityFrame {
    let image: NSImage
    let frame: CGRect
    let sprite: String?
    let entityId: String
}

extension CGSize {
    func scaled(toFill size: CGSize) -> CGSize {
        if size.width > size.height {
            CGSize(width: size.width, height: height * (size.width / width))
        } else {
            CGSize(width: width * (size.height / height), height: size.height)
        }
    }
}
