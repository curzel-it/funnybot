import SwiftUI
import AVFoundation
import Foundation
import Schwifty

enum TracksToAudioComposerError: Error {
    case attemptingToComposeZeroTracks
}

class TracksToAudioComposer {
    @Inject private var config: ConfigStorageService
    @Inject private var tempFiles: TemporaryFiles
    
    func compose(tracks: [AudioTrack], duration: TimeInterval) async throws -> URL {
        let composition = AVMutableComposition()
        
        let silenceAsset = try await createSilentAudioAsset(duration: duration)
        let silenceAssetDuration = try await silenceAsset.load(.duration)
        let silenceTrack = try composition.newMutableAudioTrack()
        
        try await silenceTrack.insertTimeRange(
            .init(start: .zero, duration: silenceAssetDuration),
            of: try silenceAsset.firstTrack(withMediaType: .audio),
            at: .zero
        )
        
        for audioTrack in tracks {
            let asset = AVURLAsset(url: audioTrack.url)
            let assetDuration = try await asset.load(.duration)
            let track = try composition.newMutableAudioTrack()
            // TODO: Currently starting audio two frames later for better sync
            let frameSynchedStartTime = audioTrack.startTime + config.current.frameTime * 2
            
            try await track.insertTimeRange(
                .init(start: .zero, duration: assetDuration),
                of: try asset.firstTrack(withMediaType: .audio),
                at: CMTime(seconds: frameSynchedStartTime, preferredTimescale: 600)
            )
        }
        
        let url = tempFiles.next(withExtension: "m4a")
        let exporter = try AVAssetExportSession(
            asset: composition,
            presetName: AVAssetExportPresetAppleM4A
        ).unwrap()
        exporter.outputFileType = .m4a
        exporter.outputURL = url
        
        await exporter.export()
        if let error = exporter.error { throw error }
        return url
    }
    
    private func createSilentAudioAsset(duration: TimeInterval) async throws -> AVAsset {
        try await createSilentAudioAsset(
            duration: duration,
            url: tempFiles.next(withExtension: "m4a"),
            sampleRate: 44100,
            channelCount: 1
        )
    }
    
    private func createSilentAudioAsset(
        duration: TimeInterval,
        url: URL,
        sampleRate: Double,
        channelCount: UInt32
    ) async throws -> AVAsset {
        let durationInSamples = Int64(duration * sampleRate)
        let format = try AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: channelCount).unwrap()
        let buffer = try AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(durationInSamples)).unwrap()
        buffer.frameLength = buffer.frameCapacity
        
        // Writing buffer to temporary file
        let tempURL = tempFiles.next(withExtension: "caf")
        let audioFile = try AVAudioFile(forWriting: tempURL, settings: format.settings)
        try audioFile.write(from: buffer)
        
        let asset = AVAsset(url: tempURL)
        
        // Create a mutable composition
        let composition = AVMutableComposition()
        
        // Add an audio track to the composition
        let track = try composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid).unwrap()
        
        try await track.insertTimeRange(
            .init(start: .zero, duration: try asset.load(.duration)),
            of: asset.firstTrack(withMediaType: .audio),
            at: .zero
        )
        
        // Export the silent audio track to the specified URL
        let exporter = try AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A).unwrap()
        exporter.outputURL = url
        exporter.outputFileType = .m4a
        
        await exporter.export()
        if let error = exporter.error { throw error }
        return composition
    }
}
