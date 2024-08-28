//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import AudioKit
import AVFoundation
import Foundation
import SoundpipeAudioKit

protocol AudioFrequencyAnalysisUseCase {
    func frequencies(url: URL, fps: TimeInterval) async throws -> [Float]
}

class AudioFrequencyAnalysisUseCaseImpl: AudioFrequencyAnalysisUseCase {
    struct TappedValue {
        let pitch: Float
        let amplitude: Float
    }
    
    func frequencies(url: URL, fps: TimeInterval) async throws -> [Float] {
        let file = try AVAudioFile(forReading: url)
        let engine = AudioEngine()
        let player = try AudioPlayer(file: file).unwrap()
        
        engine.output = player
        
        var results: [TappedValue] = []
        
        let tap = PitchTap(player) { pitches, amplitudes in
            let values = zip(pitches, amplitudes).map { (pitch, amplitude) in
                TappedValue(pitch: pitch, amplitude: amplitude)
            }
            results.append(contentsOf: values)
        }
        
        try engine.start()
        player.play()
        tap.start()
        
        let interval = 1.0 / fps
        let duration = TimeInterval(file.length) / file.fileFormat.sampleRate
        var currentTime = 0.0
        
        while currentTime < duration {
            try await Task.sleep(for: .seconds(interval))
            currentTime += interval
        }
        
        tap.stop()
        player.stop()
        engine.stop()
        
        // 0.8230
        // 0.7219
        // 0.7136
        // 0.5536
        // 0.6589
        // let maxAmplitude = results.map { $0.amplitude }.max() ?? 1
        
        return results.map { value in
            let normalizedPitch = log2(value.pitch) / 12
            let normalizedAmplitude = value.amplitude // / maxAmplitude
            let combinedValue = (0.6 * normalizedPitch) + (0.4 * normalizedAmplitude)
            return combinedValue
        }
    }
}
