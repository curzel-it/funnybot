//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation
import Schwifty
import SwiftData
import Yage

class MouthOverlayUser: BodyPartOverlayUser {
    @Inject private var lipSync: LipSyncUseCase
    
    private let useLipSync = true
    private var currentlySpokenText: String?
    private var wasTalking = false
    private var isFirstSetup = true
    
    override func doUpdate(after time: TimeInterval) async {
        await super.doUpdate(after: time)
        
        var needsFirstTimeSetup = self.isFirstSetup
        self.isFirstSetup = false
        
        guard useLipSync else { return }
        
        guard let talker = subject?.capability(for: FunnybotTalkingCharacter.self) else { return }
        let phraseChanged = talker.currentlySpokenText != currentlySpokenText
        currentlySpokenText = talker.currentlySpokenText
        
        if !wasTalking && talker.isTalking || phraseChanged {
            if let url = talker.url {
                await didStartTalking(with: url)
                needsFirstTimeSetup = false
            }
        }
        if wasTalking && !talker.isTalking {
            await super.updateAnimation()
            needsFirstTimeSetup = false
        }
        wasTalking = talker.isTalking
        
        if needsFirstTimeSetup {
            await didStopTalking()
        }
    }
    
    override func buildOverlay(in world: World) -> Entity {
        let subjectId = subject?.id ?? "unknown"
        let species = Species(id: "mouth")
        return Entity(id: "\(subjectId)-mouth", species: species, in: world)
    }
    
    override func overlayReferenceFrame(for animation: String) -> CGRect? {
        character?.mouthPositions[animation]
    }
    
    override func nextAnimation() -> String {
        guard let subject else { return "closed" }
        return subject.isTalking == true ? "open" : subject.emotion.rawValue
    }
    
    override func updateAnimation() async {
        guard !useLipSync else { return }
        await super.updateAnimation()
    }
    
    private func didStopTalking() async {
        overlay?.set(state: .action(action: .init(id: "closed"), loops: nil))
        await super.updateAnimation()
    }
    
    private func didStartTalking(with url: URL) async {
        guard let subject, let overlay else { return }
        let newState = EntityState.action(action: .init(id: "open"), loops: nil)
        overlay.set(state: newState)
        
        let animatedSprite = overlay.capability(for: AnimatedSprite.self)
        let sprites = try? await lipSync.lipsSequence(speaker: subject, for: url)
        
        if let sprites, let animatedSprite {
            animatedSprite.load(spritesSequence: sprites, name: "open", state: newState, talking: true, loop: false)
        }
    }
}
