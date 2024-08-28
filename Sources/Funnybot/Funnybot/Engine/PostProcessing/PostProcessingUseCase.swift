//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation
import AVFoundation
import Schwifty

protocol VideoPostProcessingUseCase {
    func postProcess(source: URL) async throws -> URL
}

class VideoPostProcessingUseCaseImpl: VideoPostProcessingUseCase {
    @Inject private var configStorage: ConfigStorageService
    @Inject private var tempFiles: TemporaryFiles
    
    var fps: TimeInterval {
        configStorage.current.fps
    }
    
    func postProcess(source: URL) async throws -> URL {
        let asset = AVAsset(url: source)
        let composition = AVMutableComposition()
        let durationToRemove = CMTime(value: 4, timescale: Int32(fps))
        let outputURL = tempFiles.next(withExtension: "mp4")
        
        let track = try await asset.firstTrack(withMediaType: .video)
        let compositionTrack = composition.addMutableTrack(
            withMediaType: .video, 
            preferredTrackID: kCMPersistentTrackID_Invalid
        )
        try compositionTrack?.insertTimeRange(
            CMTimeRangeMake(
                start: durationToRemove,
                duration: await track.load(.timeRange).duration - durationToRemove
            ),
            of: track,
            at: .zero
        )
        
        let audioTrack = try await asset.firstTrack(withMediaType: .audio)
        let compositionAudioTrack = composition.addMutableTrack(
            withMediaType: .audio,
            preferredTrackID: kCMPersistentTrackID_Invalid
        )
        try compositionAudioTrack?.insertTimeRange(
            CMTimeRangeMake(
                start: durationToRemove,
                duration: await audioTrack.load(.timeRange).duration - durationToRemove
            ),
            of: audioTrack,
            at: .zero
        )
        
        let exportSession = try AVAssetExportSession(
            asset: composition,
            presetName: AVAssetExportPresetHighestQuality
        ).unwrap()
        
        exportSession.outputFileType = .mp4
        exportSession.outputURL = outputURL

        await exportSession.export()
        
        if let error = exportSession.error {
            throw error
        }
        return outputURL
    }
}
