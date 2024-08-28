//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import AVFoundation
import Foundation
import Schwifty
import Yage

class FunnybotTalkingCharacter: TalkingCharacter {
    private(set) var url: URL?
    
    func talk(text: String, url: URL) async throws {
        let audio = AVURLAsset(url: url)
        let duration = try await audio.durationInSeconds()
        self.url = url
        talk(text: text, duration: duration)
    }
    
    override func stopTalking() {
        super.stopTalking()
        url = nil
    }
}

extension Entity {
    private var talking: FunnybotTalkingCharacter? {
        capability(for: FunnybotTalkingCharacter.self)
    }
    
    func talk(text: String, url: URL) {
        Task {
            try await talking?.talk(text: text, url: url)
        }
    }
}
