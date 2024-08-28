//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation
import AVFoundation
import Schwifty

class SilentPausesTrimmer: SynthetizedAudioPostProcessingUseCase {
    @Inject private var analyzer: AudioVolumeAnalysisUseCase
    @Inject private var tempFiles: TemporaryFiles
    
    let silenceThreshold: Float = 0.005
    let fps: TimeInterval = 30
    let acceptedPauseTimeInFrames: Int = 6
    
    struct AudioRange {
        let keep: Bool
        let start: Int
        let duration: Int
    }
    
    struct TimeRange {
        let keep: Bool
        let range: CMTimeRange
    }
    
    func postProcess(url source: URL, volumeLevel: Float) async throws -> URL {
        let destination = tempFiles.next(withExtension: "m4a")
        
        let levels = try await analyzer.volumeLevels(url: source, fps: fps)
        let segments = aggregate(levels: levels)
        let adjustedSegments = adjustPauses(in: segments)
        let audioRanges = convertToAudioRanges(segments: adjustedSegments)
        let aggregatedRanges = aggregate(ranges: audioRanges)
        
        let timeRanges = aggregatedRanges
            .map { convertToTimeRange(audioRange: $0) }
            .filter { $0.keep }
            .map { $0.range }
        
        if timeRanges.count > 1 {
            try await assembleAudio(source: source, destination: destination, timeRanges: timeRanges)
            return destination
        } else {
            return source
        }
    }
    
    private func adjustPauses(in segments: [[Float]]) -> [[Float]] {
        var updated: [[Float]] = []
        
        for (index, segment) in segments.enumerated() {
            if index > 0, segment[0] < silenceThreshold, segment.count > acceptedPauseTimeInFrames {
                updated[index - 1] = updated[index - 1] + segment.first(acceptedPauseTimeInFrames)
                let newSegment = [] + segment.dropFirst(acceptedPauseTimeInFrames)
                updated.append(newSegment)
            } else {
                updated.append(segment)
            }
        }
        return updated
    }
    
    private func aggregate(ranges: [AudioRange]) -> [AudioRange] {
        var aggregated: [AudioRange] = []
        var currentKeep = ranges[0].keep
        var currentStart = ranges[0].start
        var currentDuration = ranges[0].duration
        
        for (index, range) in ranges.enumerated().dropFirst() {
            let isLast = index == ranges.count - 1
            
            if range.keep == currentKeep {
                currentDuration += range.duration
            }
            if range.keep != currentKeep || isLast {
                let item = AudioRange(keep: currentKeep, start: currentStart, duration: currentDuration)
                currentKeep = range.keep
                currentStart = range.start
                currentDuration = range.duration
                aggregated.append(item)
            }
        }
        
        return aggregated
    }
    
    private func aggregate(levels: [Float]) -> [[Float]] {
        var segments: [[Float]] = []
        var currentSegment: [Float] = []
        var currentSegmentIsSilent: Bool? = nil
                
        for level in levels {
            let isSilent = level < silenceThreshold
            
            if currentSegmentIsSilent == isSilent {
                currentSegment.append(level)
            } else {
                if !currentSegment.isEmpty {
                    segments.append(currentSegment)
                }
                currentSegment = [level]
                currentSegmentIsSilent = isSilent
            }
        }
        if !currentSegment.isEmpty {
            segments.append(currentSegment)
        }
        return segments
    }
    
    private func convertToAudioRanges(segments: [[Float]]) -> [AudioRange] {
        var ranges: [AudioRange] = []
        var startIndex = 0
        
        for (index, segment) in segments.enumerated() {
            let isFirst = index == 0
            let isLast = index == segments.count - 1
            let isShortPause = segment.count < acceptedPauseTimeInFrames
            let averageVolume = segment.reduce(0.0, +) / Float(segment.count)
            let isNotSilent = averageVolume > silenceThreshold
            let keep = isShortPause || isNotSilent || isFirst || isLast
            let item = AudioRange(keep: keep, start: startIndex, duration: segment.count)
            ranges.append(item)
            startIndex += segment.count
        }
        return ranges
    }
    
    private func convertToTimeRange(audioRange: AudioRange) -> TimeRange {
        let startTime = CMTime(seconds: Double(audioRange.start) / fps, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let durationTime = CMTime(seconds: Double(audioRange.duration) / fps, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let range = CMTimeRangeMake(start: startTime, duration: durationTime)
        return TimeRange(keep: audioRange.keep, range: range)
    }
    
    private func assembleAudio(source: URL, destination: URL, timeRanges: [CMTimeRange]) async throws {
        let asset = AVURLAsset(url: source)
        let assetTrack = try await asset.firstTrack(withMediaType: .audio)
        
        let composition = AVMutableComposition()
        let compositionAudioTrack = try composition.addMutableTrack(
            withMediaType: .audio,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ).unwrap()
        
        for range in timeRanges {
            try compositionAudioTrack.insertTimeRange(range, of: assetTrack, at: composition.duration)
        }
        
        let exporter = try AVAssetExportSession(
            asset: composition,
            presetName: AVAssetExportPresetAppleM4A
        ).unwrap()
        
        exporter.outputURL = destination
        exporter.outputFileType = .m4a
        
        await exporter.export()
        
        if let error = exporter.error {
            throw error
        }
    }
}
