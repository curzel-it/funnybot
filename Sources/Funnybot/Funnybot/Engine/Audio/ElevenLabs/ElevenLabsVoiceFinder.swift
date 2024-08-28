//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation
import SwiftData

class ElevenLabsVoiceFinder: VoiceFinder {
    @Inject private var api: ElevenLabsApi
    @Inject private var modelContainer: ModelContainer
    
    func listVoices() async -> [Voice] {
        await api.listVoices()
    }
    
    func voice(for name: String, in series: Series) -> String? {
        let character = series.characters?.first { $0.matches(nameOrPath: name) }
        let voice = character?.voice.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return voice.isEmpty ? nil : voice
    }
    
    func volumeLevel(for name: String, in series: Series) -> Float {
        let character = series.characters?.first { $0.matches(nameOrPath: name) }
        return Float(character?.volume ?? 100) / 100.0
    }
}
