//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Combine
import Foundation
import Schwifty
import Yage

class YageConfigBridge {
    @Inject var config: ConfigStorageService
    
    private let tag = "YageConfigBridge"
    private var disposables = Set<AnyCancellable>()
    
    init() {
        DispatchQueue.main.async { [weak self] in
            self?.bindConfig()
        }
    }
    
    private func bindConfig() {
        config.observe()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newConfig in
                guard let self else { return }
                Logger.debug(self.tag, "Updating Yage config...")
                Yage.Config.shared.pixelPerfectMovement = newConfig.renderingMode == .pixelArt
                Yage.Config.shared.frameTime = newConfig.frameTime
                Yage.Config.shared.fps = newConfig.animationsFps
            }
            .store(in: &disposables)
    }
}
