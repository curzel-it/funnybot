//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation
import Schwifty

open class TalkingCharacter: Capability {
    public private(set) var currentlySpokenText: String?
    public private(set) var isTalking: Bool = false
    
    public func talk(text: String, duration originalDuration: TimeInterval) {
        guard let subject, let world = subject.world else { return }
        let duration = originalDuration - 0.01
        let talkEndTime = subject.lastUpdateTime + duration
                
        currentlySpokenText = text
        isTalking = true
        Logger.log(tag, "Will stop talking in \(duration), at \(talkEndTime)")
        
        world.schedule(at: talkEndTime, for: subject.species.id) { [weak self] in
            guard let self else { return }
            guard self.currentlySpokenText == text else {
                Logger.log(tag, "Was supposed to stop talking, but already started to speak another line")
                return
            }
            Logger.log(tag, "Stopped talking")
            stopTalking()
        }
    }
    
    open func stopTalking() {
        currentlySpokenText = nil
        isTalking = false
    }
}

public extension Entity {
    private var talking: TalkingCharacter? {
        capability(for: TalkingCharacter.self)
    }
    
    var isTalking: Bool {
        talking?.isTalking == true
    }
    
    func talk(text: String, duration: TimeInterval) {
        talking?.talk(text: text, duration: duration)
    }
}
