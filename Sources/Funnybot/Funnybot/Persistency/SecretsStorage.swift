//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation
import KeychainAccess

protocol SecretsStorage {
    func value(forKey key: String) -> String?
    func store(_ value: String, for key: String)
}

class KeychainAccessSecretsStorage: SecretsStorage {
    private lazy var keychain: Keychain = {
        Keychain(service: "it.curzel.funnybot.secrets")
    }()
    
    func value(forKey key: String) -> String? {
        keychain[key]
    }

    func store(_ value: String, for key: String) {
        keychain[key] = value
    }
}
