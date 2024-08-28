//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation
import AVFoundation
import Schwifty

protocol VideosToVideoComposer {
    func compose(videos: [URL]) async throws -> URL
}

enum VideosToVideoComposerError: Error {
    case noVideosToMerge
}

class VideosToVideoComposerImpl: VideosToVideoComposer {
    @Inject private var tempFiles: TemporaryFiles
    
    let tag = "VideosToVideoComposerImpl"
    
    func compose(videos: [URL]) async throws -> URL {
        guard !videos.isEmpty else {
            throw VideosToVideoComposerError.noVideosToMerge
        }
        guard videos.count != 1 else {
            return videos[0]
        }
        
        let composition = AVMutableComposition()
        
        let video = try composition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ).unwrap()
        
        var insertTime = CMTime.zero
        for url in videos {
            let asset = AVAsset(url: url)
            let track = try await asset.firstTrack(withMediaType: .video)
            let trackTimeRange = try await track.load(.timeRange)
            
            try video.insertTimeRange(trackTimeRange, of: track, at: insertTime)
            insertTime = CMTimeAdd(insertTime, trackTimeRange.duration)
        }
        return try await export(composition: composition)
    }
    
    func export(composition: AVComposition) async throws -> URL {
        let url = tempFiles.next(withExtension: "mp4")

        let exporter = try AVAssetExportSession(
            asset: composition,
            presetName: AVAssetExportPresetHighestQuality
        ).unwrap()
        
        exporter.outputURL = url
        exporter.outputFileType = .mp4
        await exporter.export()
        if let error = exporter.error { throw error }
        
        return url
    }
}
