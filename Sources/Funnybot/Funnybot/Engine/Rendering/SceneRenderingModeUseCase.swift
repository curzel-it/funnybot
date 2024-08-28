//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import SwiftUI
import SwiftUI

protocol SceneRenderingModeUseCase {
    func offsetNextToEntity(for renderingMode: SceneRenderingMode, sceneWidth: CGFloat) -> CGFloat
    func availableZoomLevels(for renderingMode: SceneRenderingMode) -> [CGFloat]
    func imageInterpolation(for renderingMode: SceneRenderingMode) -> NSImageInterpolation
}

class SceneRenderingModeUseCaseImpl: SceneRenderingModeUseCase {
    @Inject private var config: ConfigStorageService
    
    var baseScale: CGFloat {
        config.current.baseScale
    }
    
    var cameraMode: CameraMode {
        config.current.cameraMode
    }
    
    func offsetNextToEntity(for renderingMode: SceneRenderingMode, sceneWidth: CGFloat) -> CGFloat {
        switch renderingMode {
        case .regular: 0
        case .pixelArt: sceneWidth/64
        }
    }
    
    func availableZoomLevels(for renderingMode: SceneRenderingMode) -> [CGFloat] {
        var levels: [CGFloat] = []
        var current: CGFloat = 1.0
        let maxZoom = maxZoom(for: renderingMode)
        
        while current <= maxZoom {
            levels.append(current)
            current += 0.5
        }
        return levels
    }
    
    func imageInterpolation(for renderingMode: SceneRenderingMode) -> NSImageInterpolation {
        switch renderingMode {
        case .regular: .high
        case .pixelArt: .none
        }
    }
    
    private func maxZoom(for renderingMode: SceneRenderingMode) -> CGFloat {
        switch renderingMode {
        case .regular: cameraMode == .singleFocusLargeViewPort ? 1.5 : 4
        case .pixelArt: CGFloat(baseScale) / 2.0
        }
    }
}
