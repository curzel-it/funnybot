import AVFoundation
import BareBones
import Foundation
import Schwifty

class ElevenLabsSynthesizer: VoiceSynthesizer {
    private let client = ElevenLabsApi()
    private let tag = "ElevenLabsSynthesizer"
    
    @Inject private var voices: VoiceFinder
    @Inject private var config: ConfigStorageService
    @Inject private var tempFiles: TemporaryFiles
    @Inject private var dubsStorage: DubsStorage
    @Inject private var audioConverter: AudioFormatConverterUseCase
    @Inject private var postProcessing: SynthetizedAudioPostProcessingUseCase
    
    func synthesize(series: Series, speaker: String, text: String, customModelName: String?) async throws -> URL {
        let url = dubsStorage.dub(speaker: speaker, line: text)
        let volume = voices.volumeLevel(for: speaker, in: series)
        
        if FileManager.default.fileExists(at: url) {
            return url
        }
        let data = try await synthesizeNow(series: series, speaker: speaker, text: text, customModelName: customModelName)
        
        let rawFile = tempFiles.next(withExtension: "m4a")
        try data.write(to: rawFile)
        
        do {
            let postProcessed = try await postProcessing.postProcess(url: rawFile, volumeLevel: volume)
            let postProcessedData = try Data(contentsOf: postProcessed)
            try? FileManager.default.removeItem(at: rawFile)
            return try dubsStorage.save(
                speaker: speaker,
                line: text,
                data: postProcessedData
            )
        } catch {
            Logger.error(tag, "Post processing error: \(error)")
            try? FileManager.default.removeItem(at: rawFile)
            throw error
        }
    }
    
    private func synthesizeNow(series: Series, speaker: String, text: String, customModelName: String?) async throws -> Data {
        Logger.debug(tag, "Synthesizing `\(speaker): \"\(text)\"`...")
        let model = model(for: customModelName)
        let voice = voice(for: speaker, in: series)
        let result = await client.textToSpeech(voice: voice, text: text, info: "", model: model)
        let mp3Url = tempFiles.next(withExtension: "mp3")
        let mp3Data = try result.unwrap()
        try mp3Data.write(to: mp3Url)
        let m4aData = try await audioConverter.convert(mp3Url, toFormat: .m4a)
        try? FileManager.default.removeItem(at: mp3Url)
        return m4aData
    }
    
    private func model(for customModelName: String?) -> ElevenLabsApiModel {
        ElevenLabsApiModel(rawValue: customModelName ?? "") ?? .monolingualV1
    }
    
    private func voice(for speaker: String, in series: Series) -> String {
        if let voice = voices.voice(for: speaker, in: series) {
            return voice
        }
        fatalError("Can't find voice for `\(speaker)`")
    }
}

