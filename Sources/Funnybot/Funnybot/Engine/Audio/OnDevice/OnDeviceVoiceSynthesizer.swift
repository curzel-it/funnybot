//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation
import Schwifty
import AVFoundation

class OnDeviceVoiceSynthesizer: VoiceSynthesizer {
    private let tag = "OnDeviceVoiceSynthesizer"
    
    @Inject private var voices: VoiceFinder
    @Inject private var config: ConfigStorageService
    @Inject private var tempFiles: TemporaryFiles
    @Inject private var dubsStorage: DubsStorage
    @Inject private var audioConverter: AudioFormatConverterUseCase
    @Inject private var postProcessing: SynthetizedAudioPostProcessingUseCase
    
    func synthesize(series: Series, speaker: String, text: String, customModelName: String?) async throws -> URL {
        guard let voiceIdentifier = voices.voice(for: speaker, in: series) else {
            throw VoiceSynthesizerError.notFound
        }
        let url = dubsStorage.dub(speaker: speaker, line: text)
        let format = url.absoluteString.components(separatedBy: ".").last!
        
        let task = Process()
        task.launchPath = "/usr/bin/say"
        task.arguments = ["-v", voiceIdentifier, "-o", url.path, "-f", format, text]
        task.launch()
        task.waitUntilExit()

        if task.terminationStatus != 0 {
            throw VoiceSynthesizerError.failedToSynthesize
        }
        return url
    }
    
    private func voice(forSpeaker speaker: String) -> String {
        switch speaker {
        case "andy": return "com.apple.voice.premium.en-GB.Malcolm.aiff"
        case "bella": return "com.apple.voice.premium.en-US.Zoe.aiff"
        case "dan": return "com.apple.voice.enhanced.en-US.Nathan.aiff"
        case "elroy": return "com.apple.voice.enhanced.en-US.Tom.aiff"
        case "chef": return "com.apple.voice.enhanced.en-GB.Daniel.aiff"
        case "janitor": return "com.apple.voice.enhanced.en-AU.Lee.aiff"
        default: return "com.apple.voice.premium.en-US.Ava.aiff"
        }
    }
    
    func availableVoices(language: String? = nil) -> [String] {
        AVSpeechSynthesisVoice
            .speechVoices()
            .filter { $0.language == language || language == nil }
            .map { $0.identifier }
    }
}
