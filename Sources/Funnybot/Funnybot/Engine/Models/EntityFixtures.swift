import Foundation
import Funnyscript
import Schwifty
import Yage

extension Entity {
    func set(position place: ScenePosition) {
        set(position: position(for: place))
    }
}

extension Entity {
    func walk(to destination: ScenePosition) {
        walk(to: position(for: destination))
    }
    
    func walk(to destination: CGPoint) {
        uninstall(Seeker.self)
        
        let seeker = Seeker()
        install(seeker)
        
        seeker.follow(destination, to: .match) { [weak self] state in
            guard state == .captured else { return }
            self?.set(position: destination)
            seeker.kill()
        }
    }
}

extension Entity {
    func place(at destination: Position) {
        set(position: position(for: destination))
    }
    
    func position(for destination: Position) -> CGPoint {
        return switch destination {
        case .entity(let id): point(nextTo: id)
        case .scenePosition(let value): position(for: value)
        }
    }
    
    func position(for destination: ScenePosition) -> CGPoint {
        @Inject var coordinates: ScenePositionCoordinatesUseCase
        return coordinates.point(position: destination, entitySize: size)
    }
    
    func point(nextTo id: String) -> CGPoint {
        @Inject var config: ConfigStorageService
        @Inject var renderingMode: SceneRenderingModeUseCase
        
        guard let target = neighboor(matching: id) else { return .zero }
        
        let cameraInsets = config.current.cameraInsets
        let adjustedFrame = frame.inset(by: cameraInsets.horizontalOnly())
        let targetFrame = target.frame.inset(by: cameraInsets.horizontalOnly())
        let width = config.current.sceneSize.width
        let padding = renderingMode.offsetNextToEntity(for: config.current.renderingMode, sceneWidth: width)
        
        if frame.origin.x < 0 || frame.origin.x >= width {
            let onRight = width - targetFrame.midX > targetFrame.midX
            let xOffset = onRight ? -(adjustedFrame.width + padding) : targetFrame.width + padding
            let position = targetFrame.origin.offset(x: xOffset)
            return position
        } else {
            let onRight = adjustedFrame.midX < targetFrame.midX
            let xOffset = onRight ? -(adjustedFrame.width + padding) : targetFrame.width + padding
            let position = targetFrame.origin.offset(x: xOffset)
            return position
        }
    }
}

extension Entity {
    func neighboor(matching something: String) -> Entity? {
        guard let scene = world as? RenderableScene else {
            fatalError("Sorry, forgot to fix this!")
        }
        return scene.entity(matching: something)
    }
}
