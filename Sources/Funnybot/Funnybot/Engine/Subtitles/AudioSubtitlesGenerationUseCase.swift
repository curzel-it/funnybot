//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import AVFoundation
import Foundation
import Speech
import Schwifty

protocol AudioSubtitlesGenerationUseCase {
    func subtitles(for source: URL, originalText: String) async throws -> [SubtitleItem]
}

enum SFSpeechBasedAudioSubtitlesGenerationError: Error {
    case missingRequiredPermission
    case generationFailedWithoutErrors
    case cancelled
}

class SFSpeechBasedAudioSubtitlesGeneration: NSObject, AudioSubtitlesGenerationUseCase {
    private let tag = "SFSpeechBasedAudioSubtitlesGeneration"
    
    func subtitles(for source: URL, originalText: String) async throws -> [SubtitleItem] {
        Logger.debug(tag, "Generating subs for \(source)")
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            SFSpeechRecognizer.requestAuthorization { status in
                if case .authorized = status {
                    continuation.resume(returning: ())
                } else {
                    let error: SFSpeechBasedAudioSubtitlesGenerationError = .missingRequiredPermission
                    continuation.resume(throwing: error)
                }
                
            }
        }
        
        let audioEngine = AVAudioEngine()
        let recognizer = try SFSpeechRecognizer().unwrap()
        
        let file = try AVAudioFile(forReading: source)
        let audioFormat = file.processingFormat
        let audioFrameCount = AVAudioFrameCount(file.length)
        let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: audioFrameCount)!
        try file.read(into: buffer)

        let playerNode = AVAudioPlayerNode()
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.outputNode, format: buffer.format)

        let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest.append(buffer)
        
        try audioEngine.start()
        playerNode.play()

        let results: [SubtitleItem] = try await withCheckedThrowingContinuation { continuation in
            var task: SFSpeechRecognitionTask?
            
            task = recognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                guard !(task?.isCancelled ?? false) else { return }
                
                guard let self else {
                    let error: SFSpeechBasedAudioSubtitlesGenerationError = .cancelled
                    continuation.resume(throwing: error)
                    return
                }
                
                if let result {
                    let transcription = result.bestTranscription
                    
                    Logger.debug(self.tag, "Got result: \(result.isFinal) \(transcription.formattedString)")
                    
                    let results = transcription.segments
                        .enumerated()
                        .map { (index, segment) in
                            SubtitleItem(
                                index: index,
                                text: segment.substring,
                                startTime: segment.timestamp,
                                duration: segment.duration
                            )
                        }
                    
                    if isGoodEnough(transcription.formattedString, for: originalText) {
                        task?.cancel()
                        continuation.resume(returning: results)
                    }
                } else if let error {
                    task?.cancel()
                    continuation.resume(throwing: error)
                } else {
                    task?.cancel()
                    let error: SFSpeechBasedAudioSubtitlesGenerationError = .generationFailedWithoutErrors
                    continuation.resume(throwing: error)
                }
            }
        }

        audioEngine.stop()
        recognitionRequest.endAudio()
        return results
    }
    
    func duration(for transcription: SFTranscription) -> TimeInterval {
        guard let last = transcription.segments.last else { return 0 }
        return last.timestamp + last.duration
    }
    
    func isGoodEnough(_ transcript: String, for original: String) -> Bool {
        let words1 = words(for: transcript)
        let words2 = words(for: original)
        return words1.count == words2.count
    }
    
    func words(for text: String) -> [String] {
        text
            .components(separatedBy: CharacterSet(charactersIn: " .,"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .sorted()
    }
}
