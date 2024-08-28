//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation
import SwiftUI
import NotAGif

@testable import Funnyscript

class MockDependencies {}

extension MockDependencies: AssetsProvider {
    func image(sprite: String?) -> ImageFrame? {
        ImageFrame()
    }
    
    func numberOfFrames(for species: String, animation: String) -> Int {
        10
    }
}

extension MockDependencies: Config {
    var useManualCamera: Bool { false }    
    var useContextAwareAutoCamera: Bool { false }
    var useLargeContextAwareAutoCamera: Bool { false }
    var useCloseUpsAutoCamera: Bool { false }
    var autoCharacterPlacement: Bool { false }
    var autoTurnToAction: Bool { false }
    var autoCamera: Bool { false }
    var frameTime: TimeInterval { 10 }
}

extension MockDependencies: VoicesProvider {
    func duration(speaker: String, text: String) async throws -> TimeInterval {
        3.2
    }
}
