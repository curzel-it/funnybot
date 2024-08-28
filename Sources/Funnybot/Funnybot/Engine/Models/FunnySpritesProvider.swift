import Combine
import Schwifty
import SwiftUI
import Yage

class FunnySpritesProvider: SpritesProvider {
    @Inject var assets: AssetsProvider
    
    override func sprite(state: EntityState) -> String {
        guard let subject else { return "" }
        let direction = subject.isLateral ? "lateral" : frontPath
        let isTalking = subject.isTalking && subject.species.hasTalkingAssets
        
        return actionPath(state: state, isTalking: isTalking)
            .replacingOccurrences(of: EntityAnimation.idling.id, with: direction)
    }
    
    private lazy var frontPath: String = {
        let species = subject?.species.id ?? ""
        for anim in ["front_still", "front", "idle", "lateral"] {
            if !assets.frames(for: species, animation: anim).isEmpty {
                return anim
            }
        }
        return "front"
    }()
    
    private lazy var walkPath: String = {
        let species = subject?.species.id ?? ""
        for anim in ["walk", "lateral"] {
            if !assets.frames(for: species, animation: anim).isEmpty {
                return anim
            }
        }
        return "lateral"
    }()
    
    private lazy var walkTalkPath: String = {
        let species = subject?.species.id ?? ""
        if !assets.frames(for: species, animation: "walk_talk").isEmpty {
            return "walk_talk"
        }
        return walkPath
    }()
    
    override func frames(state: EntityState) -> [String] {
        guard let species = subject?.species.id else { return [] }
        let path = sprite(state: state)
        return assets.frames(for: species, animation: path)
    }
    
    private func actionPath(state: EntityState, isTalking: Bool) -> String {
        switch state {
        case .action(let action, _): 
            if action.isIdling && isTalking {
                "\(action.id)_talk"
            } else {
                action.id
            }
        case .move: 
            isTalking ? "\(walkPath)_talk" : "\(walkPath)"
        }
    }
}
