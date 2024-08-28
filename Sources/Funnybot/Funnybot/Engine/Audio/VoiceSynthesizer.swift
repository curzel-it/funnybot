import AVFoundation
import Foundation

protocol VoiceSynthesizer {
    func synthesize(series: Series, speaker: String, text: String, customModelName: String?) async throws -> URL
}

protocol VoiceFinder {
    func listVoices() async -> [Voice]
    func voice(for name: String, in series: Series) -> String?
    func volumeLevel(for name: String, in series: Series) -> Float
}

enum VoiceSynthesizerError: Error {
    case notFound
    case failedToSynthesize
}

enum VoiceEngine: String, Codable, CaseIterable, FormPickerOption, CustomStringConvertible {
    case elevenLabs
    case onDevice
    
    var description: String {
        switch self {
        case .elevenLabs: "Eleven Labs"
        case .onDevice: "On-Device"
        }
    }
}
