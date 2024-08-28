//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation
import AVFoundation
import Schwifty

class CompositeAudioPostProcessing: SynthetizedAudioPostProcessingUseCase {
    let operations: [any SynthetizedAudioPostProcessingUseCase] = [
        LeadingAndTrailingSilenceTrimmer(),
        SilentPausesTrimmer()
    ]
    
    func postProcess(url source: URL, volumeLevel: Float) async throws -> URL {
        var url = source
        for operation in operations {
            url = try await operation.postProcess(url: url, volumeLevel: volumeLevel)
        }
        return url
    }
}
