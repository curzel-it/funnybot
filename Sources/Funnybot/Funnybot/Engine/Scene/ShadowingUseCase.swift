import SwiftUI
import Yage

protocol ShadowingUseCase {
    func shadow(for entityId: String) -> NSShadow?
    func shadow(for node: Entity) -> NSShadow?
}

class ShadowingUseCaseImpl: ShadowingUseCase {
    lazy var videoHeight: CGFloat = {
        @Inject var configStorage: ConfigStorageService
        return configStorage.current.videoResolution.height
    }()
    
    func shadow(for node: Entity) -> NSShadow? {
        let radius = shadowRadius(for: node)
        guard radius > 0 else { return nil }
        let shadow = NSShadow()
        shadow.shadowBlurRadius = radius
        shadow.shadowColor = .black.withAlphaComponent(0.8)
        shadow.shadowOffset = NSSize(width: 0, height: 0)
        return shadow
    }
    
    func shadow(for entityId: String) -> NSShadow? {
        let radius = shadowRadius(for: entityId)
        guard radius > 0 else { return nil }
        let shadow = NSShadow()
        shadow.shadowBlurRadius = radius
        shadow.shadowColor = .black.withAlphaComponent(0.8)
        shadow.shadowOffset = NSSize(width: 0, height: 0)
        return shadow
    }
    
    func shadowRadius(for node: Entity) -> CGFloat {
        switch true {
        case node.hasCapability(FunnybotTalkingCharacter.self): videoHeight / 75
        case node.hasCapability(MouthOverlayUser.self): videoHeight / 100
        case node.hasCapability(EyesOverlayUser.self): videoHeight / 100
        default: 0
        }
    }
    
    func shadowRadius(for entityId: String) -> CGFloat {
        switch true {
        case entityId.hasSuffix("-mouth"): videoHeight / 100
        case entityId.hasSuffix("-eyes"): videoHeight / 100
        case entityId == "background": 0
        case entityId == "backdrop": 0
        case entityId.contains("overlay"): 0
        default: videoHeight / 75
        }
    }
}
