//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation

class AnimationsProvider: Capability {
    func randomAnimation() -> EntityAnimation? {
        subject?.species.animations.randomElement()
    }
}

extension Entity {
    var animationsProvider: AnimationsProvider? {
        capability(for: AnimationsProvider.self)
    }
}
