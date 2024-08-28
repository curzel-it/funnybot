//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation
import AVFoundation

protocol AudioVolumeAnalysisUseCase {
    func volumeLevels(url: URL, fps: TimeInterval) async throws -> [Float]
}

class AudioVolumeAnalysisUseCaseImpl: AudioVolumeAnalysisUseCase {
    func volumeLevels(url: URL, fps: TimeInterval) async throws -> [Float] {
        let asset = AVURLAsset(url: url)
        let track = try await asset.firstTrack(withMediaType: .audio)
        let formatDescription = try await track.cmAudioFormatDescription()
        let audioFormat = CMAudioFormatDescriptionGetStreamBasicDescription(formatDescription)?.pointee
        guard let sampleRate = audioFormat?.mSampleRate else {
            throw NSError(domain: "Failed to get sample rate", code: -1, userInfo: nil)
        }
        
        let duration = try await asset.durationInSeconds()
        let bufferSize = Int(duration * sampleRate)
        
        let format = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: sampleRate, channels: 1, interleaved: true)!
        var audioFile: AVAudioFile
        audioFile = try AVAudioFile(forReading: asset.url, commonFormat: .pcmFormatInt16, interleaved: true)
        
        let audioBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(bufferSize))!
        
        try audioFile.read(into: audioBuffer)
        
        var volumeArray = [Float]()
        if let audioFileBuffer = audioBuffer.int16ChannelData {
            for i in 0 ..< Int(bufferSize) {
                let volume = abs(Float(audioFileBuffer.pointee[i]) / Float(Int16.max))
                volumeArray.append(volume)
            }
        }
        
        let samplesPerFrame = Int(Float(volumeArray.count) / (Float(duration) * Float(fps)))
        let numberOfFrames = Int(Float(duration) * Float(fps))
        var averagedVolumeArray = [Float]()
        
        for i in 0..<numberOfFrames {
            let startIndex = i * samplesPerFrame
            let endIndex = min(startIndex + samplesPerFrame, volumeArray.count)
            let range = startIndex..<endIndex
            let sum = volumeArray[range].reduce(0, +)
            let average = sum / Float(endIndex - startIndex)
            averagedVolumeArray.append(average)
        }
        
        return averagedVolumeArray
    }
}
