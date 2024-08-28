//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation
import Combine

protocol SoundEffectsProvider {
    func reloadAssets(with config: Config)
    func soundEffect(id: String) -> URL?
}

class SoundEffectsProviderImpl: SoundEffectsProvider {
    @Inject private var config: ConfigStorageService
    
    private var assetsById: [String: URL] = [:]
    
    private var disposables = Set<AnyCancellable>()
    private let tag = "SoundEffectsProviderImpl"
    
    init() {
        config.observe()
            .sink { [weak self] config in self?.reloadAssets(with: config) }
            .store(in: &disposables)
    }
    
    func soundEffect(id: String) -> URL? {
        assetsById[id]
    }
    
    func reloadAssets(with config: Config) {
        assetsById = assetsUrls(from: config.assetsFolder)
            .reduce(into: [String: URL]()) { previous, url in
                let id = url
                    .lastPathComponent
                    .components(separatedBy: ".")[0]
                    .replacingOccurrences(of: "overlay_blocking_", with: "")
                    .replacingOccurrences(of: "overlay_video_", with: "")
                    .replacingOccurrences(of: "overlay_", with: "")
                previous[id] = url
            }
    }
    
    private func assetsUrls(from url: URL) -> [URL] {
        FileManager.default
            .filesRecursively(from: url)
            .filter { $0.pathExtension == "m4a" }
    }
}
