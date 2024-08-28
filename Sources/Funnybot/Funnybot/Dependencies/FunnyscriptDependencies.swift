//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import AVFoundation
import Foundation
import Funnyscript
import SwiftData

extension Config: Funnyscript.Config {
    var useManualCamera: Bool {
        cameraMode == .manual
    }
    
    var useContextAwareAutoCamera: Bool {
        cameraMode == .contextAware
    }
    
    var useLargeContextAwareAutoCamera: Bool {
        cameraMode == .largeContextAware
    }
    
    var useCloseUpsAutoCamera: Bool {
        cameraMode == .closeUps || cameraMode == .singleFocusLargeViewPort
    }
}

extension FileBasedDubsStorage: Funnyscript.VoicesProvider {
    func duration(speaker: String, text: String) async throws -> TimeInterval {
        let url = dub(speaker: speaker, line: text)
        guard FileManager.default.fileExists(at: url) else {
            throw Funnyscript.VoicesProviderError.missingFile(url: url)
        }
        let asset = AVAsset(url: url)
        return try await asset.durationInSeconds()
    }
}

extension AssetsProviderImpl: Funnyscript.AssetsProvider {
    func numberOfFrames(for species: String, animation: String) -> Int {
        frames(for: species, animation: animation).count
    }
}

class FunnyscriptCharactersProvider: Funnyscript.CharactersProvider {
    @Inject private var modelContainer: ModelContainer
    
    @MainActor
    func character(nameOrPath: String) async throws -> Character {
        let descriptor = FetchDescriptor<SeriesCharacter>()
        let allCharacters = try modelContainer.mainContext.fetch(descriptor)
        let character = try allCharacters.first { $0.matches(nameOrPath: nameOrPath) }.unwrap()
        
        return Character(
            name: character.name,
            path: character.path,
            afterTalkScript: character.afterTalkScript
        )
    }
}

extension SoundEffectsProviderImpl: Funnyscript.SoundEffectsProvider {
    func duration(actor: String, animation: String) async throws -> TimeInterval {
        let url = try soundEffect(id: animation).unwrap()
        return try await AVAsset(url: url).durationInSeconds()
    }
}
