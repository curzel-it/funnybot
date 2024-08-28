//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import SwiftUI
import Combine
import Foundation
import Schwifty
import Yage

protocol HeadlessSceneRendering {
    func render(scene: RenderableScene, config: Config) async throws -> [RenderableFrame]
}

struct RenderableFrame {
    let items: [RenderableItem]
}

struct RenderableItem {
    let frame: CGRect
    let sprite: String
    let entityId: String
    let rotation: Rotation?
    let alpha: CGFloat
}

class HeadlessSceneRenderingImpl: HeadlessSceneRendering {
    @Inject var renderingMode: SceneRenderingModeUseCase
    
    var scene: RenderableScene!
    
    var frameTime: TimeInterval = 0.1
    var fps: TimeInterval = 10
    var sceneSize: CGSize = SceneSize.standard.size
    var sceneResolution: CGSize = VideoResolution.fullHd.size
    var videoResolution: CGSize = VideoResolution.fullHd.size
    var baseScale: CGFloat = 1
    var framesPerChunk: Int = 100
    var interpolation: NSImageInterpolation = .none
    
    var sceneViewport: CGRect = .zero
    var offset: CGPoint = .zero
    var zoomLevel: CGFloat = .zero
    
    let tag = "HeadlessSceneRenderingImpl"
    
    var isVerticalFormat: Bool {
        sceneViewport.width < sceneViewport.height
    }
    
    func render(scene: RenderableScene, config: Config) async throws -> [RenderableFrame] {
        self.scene = scene
        
        let startTime = Date()
        load(config: config)
        let totalFrames = Int(scene.duration * fps)
        var renderables = [RenderableFrame]()
        var progress: Int = 0
        
        for index in 0..<totalFrames {
            let newProgress = Int(100 * Float(index) / Float(totalFrames))
            if newProgress != progress {
                progress = newProgress
                Logger.debug(tag, "Compiling frames \(progress)%")
            }
            await scene.update(after: frameTime)
            updateCameraParams()
            let frame = currentFrame()
            renderables.append(frame)
        }
        
        let elapsedTime = abs(startTime.timeIntervalSinceNow)
        let timeString = String(format: "%0.2f", elapsedTime)
        Logger.debug(tag, "Done! \(timeString)s")
        
        self.scene = nil
        
        return renderables
    }
    
    func updateCameraParams() {
        sceneViewport = scene.cameraViewport
        offset = sceneViewport.origin.scaled(baseScale)
        zoomLevel = sceneSize.height / sceneViewport.height
    }
    
    func currentFrame() -> RenderableFrame {
        RenderableFrame(items: renderItems())
    }
    
    func renderItems() -> [RenderableItem] {
        var renderedItems = renderEntities()
        
        if let rendered = renderBackground() {
            renderedItems.insert(rendered, at: 0)
        }
        if let rendered = renderBackdrop() {
            renderedItems.insert(rendered, at: 0)
        }
        return renderedItems
    }
    
    func renderBackdrop() -> RenderableItem? {
        RenderableItem(
            frame: renderingFrame(entityId: "backdrop", entityFrame: backdropFrame()),
            sprite: "background_black",
            entityId: "backdrop",
            rotation: nil,
            alpha: 1
        )
    }
    
    func backdropFrame() -> CGRect {
        CGRect(
            x: -sceneSize.width / 2,
            y: -sceneSize.height / 2,
            width: sceneSize.width * 2,
            height: sceneSize.height * 2
        )
    }
    
    func renderBackground() -> RenderableItem? {
        RenderableItem(
            frame: renderingFrame(entityId: "background", entityFrame: CGRect(size: sceneSize)),
            sprite: scene.background,
            entityId: "background",
            rotation: nil,
            alpha: 1
        )
    }
    
    func renderEntities() -> [RenderableItem] {
        scene.renderableChildren
            .filter { shouldRender(entity: $0) }
            .sorted { $0.id < $1.id }
            .sorted { $0.zIndex < $1.zIndex }
            .map { child in
                RenderableItem(
                    frame: renderingFrame(entityId: child.id, entityFrame: child.frame),
                    sprite: optimizedVersion(of: child.sprite ?? ""),
                    entityId: child.id,
                    rotation: child.rotation?.rotation,
                    alpha: child.alpha
                )
            }
            .filter { !$0.sprite.isEmpty }
    }
    
    func optimizedVersion(of sprite: String) -> String {
        if isVerticalFormat {
            if sprite.starts(with: "overlay_video") {
                sprite.replacingOccurrences(of: "-", with: "_shorts-")
            } else {
                sprite
            }
        } else {
            sprite
        }
    }
    
    func renderingFrame(entityId: String, entityFrame: CGRect) -> CGRect {
        if entityId.contains("overlay_video") {
            return CGRect(size: videoResolution)
        }
        if entityId.contains("overlay_blocking") {
            return CGRect(size: videoResolution)
        }
        
        var newFrame = entityFrame
        newFrame = newFrame.scaled(baseScale)
        newFrame = newFrame.offset(x: -offset.x)
        newFrame = newFrame.offset(y: -offset.y)
        newFrame = newFrame.scaled(zoomLevel)
        return newFrame
    }
    
    func coordinatesCorrected(_ rect: CGRect) -> CGRect {
        CGRect(
            x: rect.origin.x,
            y: sceneResolution.height - rect.origin.y - rect.size.height,
            width: rect.size.width,
            height: rect.size.height
        )
    }
    
    func shouldRender(entity: Entity) -> Bool {
        if entity.species.id == "overlay_video" { return true }
        if entity.species.id == "overlay_blocking" { return true }
        if entity.alpha < 0.03 { return false }
        if entity.isOverlay { return true }
        
        let adjustedFrame = CGRect(
            x: entity.frame.origin.x,
            y: entity.frame.origin.y,
            width: entity.frame.width,
            height: entity.frame.height
        )
        if sceneViewport.intersects(adjustedFrame) {
            return true
        }
        return false
    }
    
    func load(config: Config) {
        framesPerChunk = config.framesPerChunk
        baseScale = config.baseScale
        frameTime = config.frameTime
        fps = config.fps
        sceneSize = config.sceneSize
        videoResolution = config.videoResolution
        sceneResolution = config.sceneSize.scaled(config.baseScale)
        interpolation = renderingMode.imageInterpolation(for: config.renderingMode)
    }
}
