//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation
import SwiftUI
import Combine
import Schwifty
import AskGpt

class ThirdPartySettingsViewModel: ObservableObject {
    @Inject var keyStorage: ApiKeysStorageUseCase
    @Inject var modelPreferences: GenerativeModelPreferencesUseCase
    
    @Published var chatModel: AskGptModel = .mistral
    @Published var workingModel: AskGptModel = .mistral
    
    @Published var openAiKey: String = ""
    @Published var openRouterKey: String = ""
    @Published var elevenLabsKey: String = ""
    @Published var mistralKey: String = ""
        
    weak var window: SomeWindow?
    
    private let tag = "ThirdPartySettingsViewModel"
    private var disposables = Set<AnyCancellable>()
    
    init() {
        openAiKey = keyStorage.apiKey(for: .openAi)
        openRouterKey = keyStorage.apiKey(for: .openRouter)
        elevenLabsKey = keyStorage.apiKey(for: .elevenLabs)
        mistralKey = keyStorage.apiKey(for: .mistral)
        chatModel = modelPreferences.chatModel()
        workingModel = modelPreferences.workingModel()
        
        objectWillChange
            .debounce(for: .seconds(0.1), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in self?.save() }
            .store(in: &disposables)
    }
    
    func save() {
        keyStorage.save(apiKey: openAiKey, for: .openAi)
        keyStorage.save(apiKey: openRouterKey, for: .openRouter)
        keyStorage.save(apiKey: elevenLabsKey, for: .elevenLabs)
        keyStorage.save(apiKey: mistralKey, for: .mistral)
        modelPreferences.set(chatModel: chatModel)
        modelPreferences.set(workingModel: workingModel)
    }
}

extension AskGptModel: FormPickerOption, CustomStringConvertible {
    public var description: String { name }
}

