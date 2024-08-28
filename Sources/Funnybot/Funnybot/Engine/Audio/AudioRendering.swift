import AVFoundation
import Combine
import Foundation
import Schwifty

protocol AudioRendering {
    func add(audios: [AudioTrack], to inputUrl: URL) async throws -> URL
    func progress() -> AnyPublisher<AudioRenderingProgress, Never>
}

struct AudioTrack {
    let url: URL
    let startTime: TimeInterval
}

enum AudioRenderingProgress {
    case idle
    case renderingTrack(index: Int, totalTracks: Int)
    case saving
    case done(url: URL)
}

class AudioRenderingImpl: AudioRendering {
    @Inject private var config: ConfigStorageService
    @Inject private var tempFiles: TemporaryFiles
    
    private let progressSubject = CurrentValueSubject<AudioRenderingProgress, Never>(.idle)
    
    func progress() -> AnyPublisher<AudioRenderingProgress, Never> {
        progressSubject.eraseToAnyPublisher()
    }
    
    func add(audios: [AudioTrack], to muteVideoUrl: URL) async throws -> URL {
        let muteVideoAsset = AVURLAsset(url: muteVideoUrl)
        let muteVideoAssetDuration = try await muteVideoAsset.load(.duration)
        
        let composition = AVMutableComposition()
        let videoTrack = try composition.newMutableVideoTrack()
        let audioTrack = try composition.newMutableAudioTrack()
        
        try await videoTrack.insertTimeRange(
            .init(start: .zero, duration: muteVideoAssetDuration),
            of: muteVideoAsset.firstTrack(withMediaType: .video),
            at: .zero
        )
        
        let fullAudioUrl = try await TracksToAudioComposer().compose(
            tracks: audios,
            duration: muteVideoAssetDuration.seconds
        )
        let fullAudioAsset = AVURLAsset(url: fullAudioUrl)
        let fullAudioAssetDuration = try await fullAudioAsset.load(.duration)
        
        try await audioTrack.insertTimeRange(
            .init(start: .zero, duration: fullAudioAssetDuration),
            of: fullAudioAsset.firstTrack(withMediaType: .audio),
            at: .zero
        )

        let url = tempFiles.next(withExtension: "mp4")
        let exporter = try AVAssetExportSession(
            asset: composition,
            presetName: AVAssetExportPresetHighestQuality
        ).unwrap()
        exporter.outputFileType = .mp4
        exporter.outputURL = url
        exporter.shouldOptimizeForNetworkUse = true
        
        progressSubject.send(.saving)
        
        await exporter.export()
        if let error = exporter.error { throw error }
        
        progressSubject.send(.done(url: url))
        return url
    }
}
