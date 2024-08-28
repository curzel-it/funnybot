//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation
import AskGpt

protocol GenerativeModelPreferencesUseCase {
    func chatModel() -> AskGptModel
    func set(chatModel: AskGptModel)
    func workingModel() -> AskGptModel
    func set(workingModel: AskGptModel)
}

class GenerativeModelPreferencesUseCaseImpl: GenerativeModelPreferencesUseCase {
    private let kChatModel = "kChatModel"
    private let kWorkingModel = "kWorkingModel"
    
    func chatModel() -> AskGptModel {
        let key = UserDefaults.standard.string(forKey: kChatModel)
        return AskGptModel(rawValue: key ?? "") ?? .mistral
    }
    
    func set(chatModel: AskGptModel) {
        UserDefaults.standard.set(chatModel.rawValue, forKey: kChatModel)
    }
    
    func workingModel() -> AskGptModel {
        let key = UserDefaults.standard.string(forKey: kWorkingModel)
        return AskGptModel(rawValue: key ?? "") ?? .mistral
    }
    
    func set(workingModel: AskGptModel) {
        UserDefaults.standard.set(workingModel.rawValue, forKey: kWorkingModel)
    }
}
