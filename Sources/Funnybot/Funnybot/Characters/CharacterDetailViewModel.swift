//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation
import Combine
import SwiftUI
import SwiftData

class CharacterDetailViewModel: Identifiable, ObservableObject {
    @Published var name: String
    @Published var about: String
    @Published var path: String
    @Published var usesMouthOverlay: Bool
    @Published var usesEyesOverlay: Bool
    @Published var afterTalkScript: String
    @Published var size: String
    @Published var voice: String
    @Published var quickVoice: String
    @Published var isMainCast: Bool
    @Published var customVoiceModel: ElevenLabsApiModel
    @Published var volume: String
    
    var id: UUID { character.id }
    var title: String { name }
    
    weak var tab: TabViewModel?
    private let character: SeriesCharacter
    
    @Inject private var modelContainer: ModelContainer
    
    private var disposables = Set<AnyCancellable>()
    
    init(for character: SeriesCharacter) {
        self.character = character
        afterTalkScript = character.afterTalkScript
        name = character.name
        about = character.about
        path = character.path
        size = "\(character.size)"
        volume = "\(character.volume)"
        voice = character.voice
        quickVoice = character.quickVoice ?? ""
        usesMouthOverlay = character.usesMouthOverlay
        usesEyesOverlay = character.usesEyesOverlay
        isMainCast = character.isMainCast
        customVoiceModel = ElevenLabsApiModel(rawValue: character.customVoiceModel) ?? .monolingualV1
        bindAutoSave()
    }
    
    private func bindAutoSave() {
        objectWillChange
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                Task { @MainActor in
                    self.save()
                }
            }
            .store(in: &disposables)
    }
    
    @MainActor
    func save() {
        character.name = name
        character.about = about
        character.path = path
        character.size = Int(size) ?? character.size
        character.voice = voice
        character.quickVoice = quickVoice
        character.usesMouthOverlay = usesMouthOverlay
        character.usesEyesOverlay = usesEyesOverlay
        character.isMainCast = isMainCast
        character.afterTalkScript = afterTalkScript
        character.customVoiceModel = customVoiceModel.rawValue
        character.volume = Int(volume) ?? character.volume
        modelContainer.mainContext.insert(character)
        try? modelContainer.mainContext.save()
    }
    
    @MainActor
    func showBodyBuilder() {
        tab?.navigate(to: .bodyBuilder(character: character))
    }
    
    @MainActor
    func delete(goBack: Bool = true) {
        modelContainer.mainContext.delete(character)
        try? modelContainer.mainContext.save()
        if goBack {
            tab?.navigateBack()
        }
    }
    
    @MainActor
    func onDisappear() {
        if character.modelContext == nil {
            delete(goBack: false)
        }
    }
}
