//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import SwiftUI
import AVFoundation
import Combine
import Foundation
import Schwifty

protocol EpisodeRendering {
    func render(episode: Episode, handler: @escaping EpisodeRenderingHandler) async throws -> URL
}

typealias EpisodeRenderingHandler = (EpisodeRenderingProgress) -> Void

enum EpisodeRenderingProgress {
    case compiling
    case rendering(rendered: Int, total: Int)
    case saving
    case done
}

extension EpisodeRenderingProgress: CustomStringConvertible {
    var description: String {
        switch self {
        case .compiling: "Compiling"
        case .rendering(let frames, let total): "Rendering \(frames) out of \(total)"
        case .saving: "Saving"
        case .done: "Done"
        }
    }
    
    var progress: Float? {
        switch self {
        case .compiling: nil
        case .rendering(let frames, let total): Float(frames) / Float(total)
        case .saving: nil
        case .done: nil
        }
    }
}

enum EpisodeRenderingError: Error {
    case cancelled
    case couldNotAddInputToAssetWriter
    case couldNotCreateImageContext
    case couldNotCreateCGImage
    case couldNotCreatePixelBuffer
    case badPixelBufferStatus
    case generic(error: Error)
}
