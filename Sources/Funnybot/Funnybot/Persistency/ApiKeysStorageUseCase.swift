//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation

protocol ApiKeysStorageUseCase {
    func apiKey(for service: ThirdPartyService) -> String
    func save(apiKey: String, for service: ThirdPartyService)
}

enum ThirdPartyService: String {
    case elevenLabs
    case mistral
    case openAi
    case openRouter
}

class SecureApiKeysStorageUseCase: ApiKeysStorageUseCase {
    @Inject var storage: SecretsStorage
    
    func apiKey(for service: ThirdPartyService) -> String {
        storage.value(forKey: key(for: service)) ?? ""
    }
    
    func save(apiKey: String, for service: ThirdPartyService) {
        storage.store(apiKey, for: key(for: service))
    }
    
    func key(for service: ThirdPartyService) -> String {
        "thirdParties.\(service.rawValue)"
    }
}
