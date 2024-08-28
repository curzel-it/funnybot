//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation
import Funnyscript
import Schwifty
import SwiftData
import Yage

class Emotional: Capability {
    var emotion: Emotion = .normal
}

extension Entity {
    private var emotional: Emotional? {
        capability(for: Emotional.self)
    }
    
    var emotion: Emotion {
        get { emotional?.emotion ?? .normal }
        set { emotional?.emotion = newValue }
    }
}
