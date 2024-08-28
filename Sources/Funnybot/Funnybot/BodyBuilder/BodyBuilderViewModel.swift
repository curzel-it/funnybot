//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Combine
import Foundation
import NotAGif
import Schwifty
import SwiftData
import SwiftUI
import Yage

class BodyBuilderViewModel: ObservableObject {
    @Inject private var paths: PathsUseCase
    @Inject private var viewScreenshot: ViewScreenshotUseCase
    @Inject private var imageRepresentations: ImageRepresentationsUseCase
    
    @Published var animations: [String] = []
    @Published var selectedAnimation: String = "front"
    @Published var characterSprite: ImageFrame = .init()
    
    @Published var mouthSize: CGFloat = 0
    @Published var mouthX: CGFloat = 0
    @Published var mouthY: CGFloat = 0
    @Published var mouthSizeString: String = "10"
    @Published var mouthSpriteName: String = "mouth_open-10"
    @Published var mouthXString: String = "0"
    @Published var mouthYString: String = "0"
    @Published var mouthColor: Color = .clear
    @Published var mouthSprites: [String] = []
    var mouthSprite: ImageFrame = .init()
    
    @Published var eyesModifier: String = ""
    @Published var eyesSize: CGFloat = 0
    @Published var eyesX: CGFloat = 0
    @Published var eyesY: CGFloat = 0
    @Published var eyesSizeString: String = "10"
    @Published var eyesXString: String = "0"
    @Published var eyesYString: String = "0"
    @Published var eyesColor: Color = .clear
    var eyesSprite: ImageFrame = .init()
    
    var eyesSpriteSize: CGFloat {
        eyesSize * canvasSize
    }
    
    var eyesSpriteOffsetX: CGFloat {
        eyesX * canvasSize - canvasSize/2 + eyesSpriteSize/2
    }
    
    var eyesSpriteOffsetY: CGFloat {
        eyesY * canvasSize - canvasSize/2 + eyesSpriteSize/2
    }
    
    var mouthSpriteSize: CGFloat {
        mouthSize * canvasSize
    }
    
    var mouthSpriteOffsetX: CGFloat {
        mouthX * canvasSize - canvasSize/2 + mouthSpriteSize/2
    }
    
    var mouthSpriteOffsetY: CGFloat {
        mouthY * canvasSize - canvasSize/2 + mouthSpriteSize/2
    }
    
    weak var tab: TabViewModel?
    
    lazy var canvasSize: CGFloat = {
        (Screen.main?.bounds.width ?? 0) > 1920 ? 1000 : 500
    }()
    
    let character: SeriesCharacter
    
    private var disposables = Set<AnyCancellable>()
    
    @Inject private var dispatcher: ActionsDispatcher
    @Inject private var assets: AssetsProvider
    @Inject private var modelContainer: ModelContainer
    
    init(character: SeriesCharacter) {
        self.character = character
        self.eyesModifier = character.eyesModifier ?? ""
        loadAnimations()
        loadMouthOptions()
        bindSelectedAnimation()
        bindMouthSpriteName()
        loadEyesSprite()
        loadMouthSprite()
    }
    
    @MainActor
    func save() {
        try? modelContainer.mainContext.save()
    }
    
    @MainActor
    func cancel() {
        tab?.navigateBack()
    }
    
    private func loadMouthOptions() {
        mouthSprites = assets.allSprites(withPrefix: "mouth_")
    }
    
    private func bindMouthSpriteName() {
        $mouthSpriteName
            .receive(on: DispatchQueue.main)
            .delay(for: .seconds(0.1), scheduler: DispatchQueue.main)
            .sink { [weak self] sprite in self?.loadMouthSprite(sprite: sprite) }
            .store(in: &disposables)
    }
    
    private func bindSelectedAnimation() {
        $selectedAnimation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.selectedAnimationChanged(to: $0) }
            .store(in: &disposables)
    }
    
    @MainActor
    func update() {
        eyesX = CGFloat(Float(eyesXString) ?? 0) / 1000
        eyesY = CGFloat(Float(eyesYString) ?? 0) / 1000
        eyesSize = CGFloat(Float(eyesSizeString) ?? 0) / 1000
        
        let eyesModifier = self.eyesModifier.trimmingCharacters(in: .whitespacesAndNewlines)
        character.eyesModifier = eyesModifier.isBlank ? nil : eyesModifier
        
        let eyesFrame = CGRect(x: eyesX, y: eyesY, width: eyesSize, height: eyesSize)
        character.eyesPositions[selectedAnimation] = eyesFrame
        loadEyesSprite()
        
        mouthX = CGFloat(Float(mouthXString) ?? 0) / 1000
        mouthY = CGFloat(Float(mouthYString) ?? 0) / 1000
        mouthSize = CGFloat(Float(mouthSizeString) ?? 0) / 1000
        
        let mouthFrame = CGRect(x: mouthX, y: mouthY, width: mouthSize, height: mouthSize)
        character.mouthPositions[selectedAnimation] = mouthFrame
        loadMouthSprite()
        
        save()
    }
    
    func export() {
        let view = BodyPreview(size: canvasSize).environmentObject(self)
        Task {
            let image = await viewScreenshot.screenshot(view, size: CGSize(square: canvasSize))
            
            let url = paths
                .charactersFolder(for: character)
                .appendingPathComponent(filename(), conformingTo: .png)
            
            guard let data = imageRepresentations.png(from: image) else { return }
            
            do {
                try FileManager.default.createIntermediateDirectories(toFile: url)
                try data.write(to: url)
                url.visit()
            } catch {
                Logger.error("Failed to save image: \(error)")
            }
        }
    }
    
    private func filename() -> String {
        [character.name, selectedAnimation]
            .joined(separator: "_")
            .appending(".png")
    }
    
    private func loadEyesSprite() {
        let eyesModifier = self.eyesModifier.trimmingCharacters(in: .whitespacesAndNewlines)
        let direction = selectedAnimation == "lateral" ? "lateral" : "front"
        let modifier = eyesModifier.isBlank ? "" : "_\(eyesModifier)"
        let newSpriteName = "eyes_\(direction)\(modifier)-1"
        eyesSprite = assets.image(sprite: newSpriteName) ?? .init()
    }
    
    private func loadMouthSprite(sprite: String? = nil) {
        mouthSprite = assets.image(sprite: sprite ?? mouthSpriteName) ?? .init()
    }
    
    private func selectedAnimationChanged(to animationName: String) {
        loadCharacterSprite(animation: animationName)
        
        let mouthFrame = character.mouthPositions[animationName] ?? CGRect(square: 0.01)
        mouthX = mouthFrame.origin.x
        mouthXString = "\(Int(mouthFrame.origin.x * 1000))"
        mouthY = mouthFrame.origin.y
        mouthYString = "\(Int(mouthFrame.origin.y * 1000))"
        mouthSize = mouthFrame.width
        mouthSizeString = "\(Int(mouthFrame.width * 1000))"
        
        let eyesFrame = character.eyesPositions[animationName] ?? CGRect(square: 0.01)
        eyesX = eyesFrame.origin.x
        eyesXString = "\(Int(eyesFrame.origin.x * 1000))"
        eyesY = eyesFrame.origin.y
        eyesYString = "\(Int(eyesFrame.origin.y * 1000))"
        eyesSize = eyesFrame.width
        eyesSizeString = "\(Int(eyesFrame.width * 1000))"
        
        loadMouthSprite()
        loadEyesSprite()
    }
    
    private func loadCharacterSprite(animation animationName: String) {
        let entity = dispatcher.entity(for: character.name, series: character.series)
        let animation = EntityAnimation(id: animationName)
        let state: EntityState = .action(action: animation, loops: nil)
        let sprite = entity.spritesProvider?.frames(state: state).first ?? ""
        characterSprite = assets.image(sprite: sprite) ?? .init()
    }
    
    private func loadAnimations() {
        let entity = dispatcher.entity(for: character.name, series: character.series)
        animations = assets.availableAnimations(forSpecies: entity.species.id).sorted()
    }
}

extension String: FormPickerOption {}
