import Foundation
import Schwifty
import SwiftUI

protocol CameraAgent {
    func viewport(subjects: [CGRect]) -> CGRect
}

class CameraAgentImpl: CameraAgent {
    @Inject private var configStorage: ConfigStorageService
    @Inject private var renderingMode: SceneRenderingModeUseCase
    
    private var config: Config {
        configStorage.current
    }
    
    private lazy var defaultViewport: CGRect = {
        makeViewport(sceneFrame) ?? CGRect(size: config.videoResolution)
    }()
    
    private lazy var sceneFrame: CGRect = {
        CGRect(size: config.sceneSize)
    }()
    
    private lazy var aspectRatio: CGFloat = {
        config.videoResolution.width / config.videoResolution.height
    }()
    
    private lazy var insets: NSEdgeInsets = {
        config.cameraInsets
    }()
    
    private lazy var sceneScaleViewportSize: CGSize = {
        CGSize(width: aspectRatio * config.sceneSize.height, height: config.sceneSize.height)
    }()
    
    private let tag = "CameraAgentImpl"
    
    func viewport(subjects sceneFrames: [CGRect]) -> CGRect {
        guard !sceneFrames.isEmpty else {
            Logger.debug(tag, "Using default viewport")
            return defaultViewport
        }
        
        let frames = sceneFrames.map { $0.inset(by: insets) }
        let framesString = frames.map { $0.viewportString }.joined(separator: ", ")
        Logger.debug(tag, "Finding Viewport for", framesString)
        
        do {
            var viewport = try frames.smallestEnclosingRectangle().unwrap()
            viewport = try makeViewport(viewport).unwrap()
            viewport = fit(viewport, within: sceneFrame)
            return viewport
        } catch {
            return viewport(subjects: sceneFrames.byRemovingLast())
        }
    }
    
    func fit(_ rect: CGRect, within bounds: CGRect) -> CGRect {
        var newRect = rect
        if rect.origin.x < bounds.origin.x {
            newRect = newRect.offset(x: bounds.origin.x - rect.origin.x)
        }
        if rect.origin.y < bounds.origin.y { 
            newRect = newRect.offset(y: bounds.origin.y - rect.origin.y)
        }
        if (rect.origin.x + rect.width) > (bounds.origin.x + bounds.width) {
            newRect = newRect.offset(x: (bounds.origin.x + bounds.width) - (rect.origin.x + rect.width))
        }
        if (rect.origin.y + rect.height) > (bounds.origin.y + bounds.height) {
            newRect = newRect.offset(y: (bounds.origin.y + bounds.height) - (rect.origin.y + rect.height))
        }
        return newRect
    }
    
    func makeViewport(_ rect: CGRect) -> CGRect? {
        availableSizes()
            .reversed()
            .filter { $0.width >= rect.width && $0.height >= rect.height }
            .map { CGRect(center: rect.center, size: $0) }
            .first
    }
    
    private func availableSizes() -> [CGSize] {
        renderingMode.availableZoomLevels(for: config.renderingMode)
            .map { 1 / $0 }
            .map { sceneScaleViewportSize.scaled($0) }
            .map { CGSize(width: Int($0.width), height: Int($0.height)) }
    }
}

extension CGRect {
    init(center: CGPoint, size: CGSize) {
        self.init(
            x: center.x - size.width/2,
            y: center.y - size.height/2,
            width: size.width,
            height: size.height
        )
    }
}
