//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation
import AVFoundation
import Schwifty

class LeadingAndTrailingSilenceTrimmer: SynthetizedAudioPostProcessingUseCase {
    @Inject private var analyzer: AudioVolumeAnalysisUseCase
    @Inject private var tempFiles: TemporaryFiles
    
    let silenceThreshold: Float = 0.005
    let fps: TimeInterval = 30
    
    func postProcess(url source: URL, volumeLevel: Float) async throws -> URL {
        let destination = tempFiles.next(withExtension: "m4a")
        let levels = try await analyzer.volumeLevels(url: source, fps: fps)
        
        let firstSoundFrame = try? levels.firstIndex { $0 > silenceThreshold }.unwrap()
        guard var firstSoundFrame else { return source }
                
        let lastSoundFrame = try? levels.lastIndex { $0 > silenceThreshold }.unwrap()
        guard var lastSoundFrame else { return source }
        lastSoundFrame = min(lastSoundFrame + 5, levels.count - 1)
        firstSoundFrame = max(0, firstSoundFrame - 1)
        
        let startTime = TimeInterval(firstSoundFrame) / fps
        let endTime = TimeInterval(lastSoundFrame) / fps
        
        let audioAsset = AVURLAsset(url: source, options: nil)
        
        let timescale = try await audioAsset.load(.duration).timescale
        let cmStartTime = CMTime(seconds: startTime, preferredTimescale: timescale)
        let cmEndTime = CMTime(seconds: endTime, preferredTimescale: timescale)
        let timeRange = CMTimeRangeFromTimeToTime(start: cmStartTime, end: cmEndTime)
        
        let exportSession = try AVAssetExportSession(
            asset: audioAsset,
            presetName: AVAssetExportPresetAppleM4A
        ).unwrap()
        
        let audioMix = AVMutableAudioMix()
        let track = try await audioAsset.firstTrack(withMediaType: .audio)
        let inputParams = AVMutableAudioMixInputParameters(track: track)
        inputParams.setVolume(volumeLevel, at: CMTime.zero)
        audioMix.inputParameters = [inputParams]
        
        exportSession.audioMix = audioMix
        exportSession.outputURL = destination
        exportSession.outputFileType = .m4a
        exportSession.timeRange = timeRange
        
        await exportSession.export()
        
        if let error = exportSession.error {
            throw error
        }
        return destination
    }
}
