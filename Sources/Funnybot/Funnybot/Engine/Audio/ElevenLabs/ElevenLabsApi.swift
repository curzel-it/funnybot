import BareBones
import Foundation
import Schwifty

class ElevenLabsApi {
    let client: HttpClient
    
    private let tag = "ElevenLabsApi"
    
    init() {
        @Inject var storage: ApiKeysStorageUseCase
        
        client = HttpClient(baseUrl: "https://api.elevenlabs.io", logResponses: true)
        client.httpHeaders = [
            "Accept": "application/mpeg",
            "Content-Type": "application/json",
            "xi-api-key": storage.apiKey(for: .elevenLabs)
        ]
    }
    
    func listVoices() async -> [Voice] {
        let response: Result<VoicesResponse, Error> = await client.get(from: "v1/voices")
        return (try? response.unwrap().voices) ?? []
    }
    
    func textToSpeech(voice: String, text: String, info: String, model: ElevenLabsApiModel) async -> Result<Data, Error> {
        // TODO: Implement emotions?
        // See https://github.com/lugia19/ElvenLabsWhisperXSplit
        // Then: let prompt = "\"\(text)\" \(info)"
        // OR, Even better: https://elevenlabslib.readthedocs.io/en/latest/source/examples.html#use-prompting-to-add-emotion
        let request = TextToSpeechRequest(text: text, model: model)
        let result = await client.data(
            via: .post,
            to: "v1/text-to-speech/\(voice)",
            with: .body(body: request)
        )
        
        switch result {
        case .success(let data):
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                Logger.log(tag, "Synthesis error for \(text) @ \(voice): \(errorResponse)")
                return .failure(ElevenLabsApiError.failedToSynthesize)
            } else {
                return result
            }
        case .failure(let error):
            Logger.log(tag, "Synthesis error for \(text) @ \(voice): \(error)")
            return result
        }
    }
    
    struct TextToSpeechRequest: Encodable {
        let text: String
        let model: ElevenLabsApiModel
        let voiceSettings = VoiceSettings()
        
        enum CodingKeys: String, CodingKey {
            case voiceSettings = "voice_settings"
            case text
            case model = "model_id"
        }
    }
    
    struct VoiceSettings: Encodable {
        let stability = 0.5
        let similarityBoost = 0.5
        
        enum CodingKeys: String, CodingKey {
            case similarityBoost = "similarity_boost"
            case stability
        }
    }
}

enum ElevenLabsApiModel: String, CaseIterable, Codable, CustomStringConvertible {
    case monolingualV1 = "eleven_monolingual_v1"
    case multilingualV2 = "eleven_multilingual_v2"
    
    var description: String {
        rawValue.replacingOccurrences(of: "_", with: " ").capitalized
    }
}

enum ElevenLabsApiError: Error {
    case failedToSynthesize
}

struct Voice: Codable {
    let name: String
    let id: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case id = "voice_id"
    }
}

private struct VoicesResponse: Codable {
    let voices: [Voice]
}

private struct ErrorResponse: Codable {
    let detail: ErrorResponseDetail
}

private struct ErrorResponseDetail: Codable {
    let status: String
}

extension String {
    func truncate(to maxLength: Int) -> String {
        count <= maxLength ? self : String(prefix(maxLength))
    }
}
