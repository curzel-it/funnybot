//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation
import AVFoundation
import Schwifty

protocol SynthetizedAudioPostProcessingUseCase {
    func postProcess(url: URL, volumeLevel: Float) async throws -> URL
}
