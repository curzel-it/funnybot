//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation
import Funnyscript

protocol ScenePositionCoordinatesUseCase {
    func point(position: ScenePosition, entitySize: CGSize) -> CGPoint
}

class ConfigAwareScenePositionCoordinatesUseCase: ScenePositionCoordinatesUseCase {
    @Inject private var config: ConfigStorageService
    
    var sceneSize: CGSize {
        config.current.sceneSize
    }
    
    func point(position: ScenePosition, entitySize: CGSize) -> CGPoint {
        CGPoint(
            x: Int(x(for: position, entityWidth: entitySize.width)),
            y: Int(y(for: position, entityHeight: entitySize.height))
        )
    }
}

private extension ConfigAwareScenePositionCoordinatesUseCase {
    func x(for position: ScenePosition, entityWidth: CGFloat) -> CGFloat {
        sceneSize.width * xMultiplier(for: position) + xOffset(for: position, entityWidth: entityWidth)
    }
    
    func xMultiplier(for position: ScenePosition) -> CGFloat {
        switch (position.side, position.horizontalModifier) {
        case (.left, .outside): 0
        case (.left, .far): 0
        case (.left, .mid): 0.2
        case (.left, .center): 0.4
        case (.none, .center): 0.5
        case (.right, .center): 0.6
        case (.right, .mid): 0.8
        case (.right, .far): 1
        case (.right, .outside): 1
        default: 10
        }
    }
    
    func xOffset(for position: ScenePosition, entityWidth: CGFloat) -> CGFloat {
        let minusHalfWidth = -entityWidth/2
        return switch (position.side, position.horizontalModifier) {
        case (.left, .outside): -entityWidth
        case (.left, .far): 0
        case (.left, .mid): minusHalfWidth + 15
        case (.left, .center): minusHalfWidth
        case (.none, .center): minusHalfWidth
        case (.right, .center): minusHalfWidth
        case (.right, .mid): minusHalfWidth - 15
        case (.right, .far): -entityWidth
        case (.right, .outside): 0
        default: 0
        }
    }
    
    func y(for position: ScenePosition, entityHeight: CGFloat) -> CGFloat {
        sceneSize.height * yMultiplier(for: position) + yOffset(for: position, entityHeight: entityHeight)
    }
    
    func yMultiplier(for position: ScenePosition) -> CGFloat {
        switch position.verticalModifier {
        case .below: 0
        case .bottom: 0
        case .mid: CGFloat(config.current.yMultiplierVerticalMid)
        case .high: 0.6
        case .top: 1
        case .over: 1
        }
    }
    
    func yOffset(for position: ScenePosition, entityHeight: CGFloat) -> CGFloat {
        switch position.verticalModifier {
        case .below: -entityHeight
        case .bottom: 0
        case .mid: 0
        case .high: 0
        case .top: -entityHeight
        case .over: entityHeight
        }
    }
}
