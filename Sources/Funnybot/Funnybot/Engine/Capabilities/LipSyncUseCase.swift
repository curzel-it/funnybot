//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import AVFoundation
import Foundation
import Schwifty
import Yage

protocol LipSyncUseCase {
    func lipsSequence(speaker: Entity, for url: URL) async throws -> [String]
}

class LipSyncUseCaseImpl: LipSyncUseCase {
    @Inject private var config: ConfigStorageService
    @Inject private var volumeAnalyzer: AudioVolumeAnalysisUseCase
    
    private let tag = "LipSyncUseCaseImpl"
    
    private let closedMouthThreshold: Float = 0.01
    private let largeMouthThreshold: Float = 0.15
    private let closedMouthClosed = "mouth_closed-0"
    
    private let largeOpenMouths = [
        "mouth_open-5",
        "mouth_open-7",
        "mouth_open-14",
        "mouth_open-20",
        "mouth_open-23",
        "mouth_open-24"
    ]
    
    private let regularOpenMouths = [
        "mouth_open-0",
        "mouth_open-1",
        "mouth_open-2",
        "mouth_open-3",
        "mouth_open-4",
        "mouth_open-6",
        "mouth_open-8",
        "mouth_open-9",
        "mouth_open-10",
        "mouth_open-11",
        "mouth_open-13",
        "mouth_open-15",
        "mouth_open-16",
        "mouth_open-17",
        "mouth_open-18",
        "mouth_open-19",
        "mouth_open-21",
        "mouth_open-22"
    ]
    
    
    func lipsSequence(speaker: Entity, for url: URL) async throws -> [String] {
        let fps = config.current.animationsFps
        let samples: TimeInterval = fps / 3
        let repetitionsPerSample: Int = 3
        let volumeLevels = try await volumeAnalyzer.volumeLevels(url: url, fps: samples)
        
        var regularMouthIndex = 0
        var largeMouthIndex = 0
        
        let sprites = volumeLevels.map { volumeLevel in
            if volumeLevel < closedMouthThreshold {
                return "mouth_closed-0"
            }
            if volumeLevel < largeMouthThreshold {
                regularMouthIndex = regularMouthIndex + 1
                if regularMouthIndex >= regularOpenMouths.count {
                    regularMouthIndex = 0
                }
                return regularOpenMouths[regularMouthIndex]
            } else {
                largeMouthIndex = largeMouthIndex + 1
                if largeMouthIndex >= largeOpenMouths.count {
                    largeMouthIndex = 0
                }
                return largeOpenMouths[largeMouthIndex]
            }
        }       
        
        let multipliedSprites = sprites.flatMap {
            [String](repeating: $0, count: repetitionsPerSample)
        }
        
        let padded = [
            (multipliedSprites.first?.contains("closed") ?? false) ? [] : [closedMouthClosed],
            multipliedSprites,
            (multipliedSprites.last?.contains("closed") ?? false) ? [] : [closedMouthClosed]
        ]
            .flatMap { $0 }
        
        return padded
    }
}
