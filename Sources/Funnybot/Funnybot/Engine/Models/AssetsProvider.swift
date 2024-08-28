import NotAGif
import Combine
import NotAGif
import Schwifty
import SwiftUI

protocol AssetsProvider {
    func reloadAssets(with config: Config)
    func availableAnimations(forSpecies species: String) -> [String]
    func frames(for species: String, animation: String) -> [String]
    func images(for species: String, animation: String) -> [ImageFrame]
    func image(sprite: String?) -> ImageFrame?
    func image(named: String) -> ImageFrame?
    func allSprites(withPrefix prefix: String) -> [String]
}

class AssetsProviderImpl: AssetsProvider {
    @Inject private var config: ConfigStorageService
    
    private var allAssetsUrls: [URL] = []
    private var sortedAssetsByKey: [String: [Asset]] = [:]
    private var disposables = Set<AnyCancellable>()
    private let tag = "AssetsProviderImpl"
    
    init() {
        config.observe()
            .sink { [weak self] config in self?.reloadAssets(with: config) }
            .store(in: &disposables)
    }
    
    func frames(for species: String, animation: String) -> [String] {
        let assets = sortedAssetsByKey[key(for: species, animation: animation)] ?? []
        return assets.map { $0.sprite }
    }
    
    func images(for species: String, animation: String) -> [ImageFrame] {
        frames(for: species, animation: animation)
            .compactMap { image(sprite: $0) }
    }
    
    func image(sprite: String?) -> ImageFrame? {
        guard let sprite else { return nil }
        guard let url = url(sprite: sprite) else { return nil }
        return image(url: url)
    }
    
    func image(named name: String) -> ImageFrame? {
        let filename = name.hasSuffix("png") ? name : "\(name).png"
        let url = allAssetsUrls.first { $0.lastPathComponent == filename }
        guard let url else { return nil }
        return image(url: url)
    }
    
    func allSprites(withPrefix prefix: String) -> [String] {
        sortedAssetsByKey
            .flatMap { (_, value) in value }
            .map { $0.sprite }
            .filter { $0.hasPrefix(prefix) }
            .sorted()
    }
    
    private func image(url: URL) -> ImageFrame? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        guard let bitmapRep = NSBitmapImageRep(data: data) else { return nil }
        
        let image = NSImage(size: NSMakeSize(CGFloat(bitmapRep.pixelsWide), CGFloat(bitmapRep.pixelsHigh)))
        image.addRepresentation(bitmapRep)
        return image
    }
    
    func availableAnimations(forSpecies species: String) -> [String] {
        sortedAssetsByKey.keys
            .filter { $0.hasPrefix("\(species)_") }
            .map { $0.replacingOccurrences(of: species, with: "") }
            .map { $0.trimmingCharacters(in: CharacterSet(charactersIn: "_")) }
    }
    
    func reloadAssets(with config: Config) {
        Logger.debug(tag, "Config changed, reloading assets")
        
        allAssetsUrls = assetsUrls(from: config.assetsFolder)
        
        let tempAssets = allAssetsUrls
            .map { Asset(url: $0) }
            .sorted { $0.frame < $1.frame }
        
        let unpackedAssets = tempAssets.flatMap { unpack(asset: $0, with: tempAssets) }
        
        sortedAssetsByKey = unpackedAssets.reduce([String: [Asset]](), { previousCache, asset in
                var cache = previousCache
                let previousFrames = (cache[asset.key] ?? []).map { $0.frame }
                if !previousFrames.contains(asset.frame) {
                    cache[asset.key] = (cache[asset.key] ?? []) + [asset]
                }
                return cache
            })
    }
    
    private func unpack(asset: Asset, with otherAssets: [Asset]) -> [Asset] {
        let currentFrame = asset.frame
        let nextFrame = otherAssets
            .filter { $0.key == asset.key }
            .sorted { $0.frame < $1.frame }
            .first { $0.frame > currentFrame }?
            .frame
        
        guard let nextFrame else { return [asset] }
        
        let numberOfMissingFrame = nextFrame - currentFrame
        return (0...numberOfMissingFrame)
            .map { currentFrame + $0 }
            .map { Asset(url: asset.url, key: asset.key, sprite: asset.sprite, frame: $0) }
    }
    
    private func url(sprite: String) -> URL? {
        guard let key = key(fromSprite: sprite) else { return nil }
        return sortedAssetsByKey[key]?
            .filter { $0.sprite == sprite }
            .first?
            .url
    }
    
    private func key(for species: String, animation: String) -> String {
        "\(species)_\(animation)"
    }
    
    private func key(fromSprite sprite: String) -> String? {
        sprite.components(separatedBy: "-").first
    }
    
    private func assetsUrls(from url: URL) -> [URL] {
        FileManager.default
            .filesRecursively(from: url)
            .filter { $0.pathExtension == "png" }
    }
}

private struct Asset {
    let url: URL
    let key: String
    let sprite: String
    let frame: Int
    
    init(url: URL) {
        self.url = url
        let sprite = url.spriteName
        let tokens = sprite.components(separatedBy: "-")
        key = tokens.first ?? ""
        frame = Int(tokens.last ?? "") ?? 0
        self.sprite = sprite
    }
    
    init(url: URL, key: String, sprite: String, frame: Int) {
        self.url = url
        self.key = key
        self.sprite = sprite
        self.frame = frame
    }
}

private extension URL {
    var spriteName: String {
        lastPathComponent
            .components(separatedBy: ".")
            .first ?? ""
    }
}
