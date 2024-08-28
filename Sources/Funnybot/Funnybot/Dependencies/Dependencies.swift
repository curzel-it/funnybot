//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Combine
import Funnyscript
import Schwifty
import Swinject
import SwiftData
import SwiftUI
import Yage

class Dependencies {
    @MainActor
    static func setup() {
        registerYageCapabilities()
        Container.mainSource = dependencyContainer()
        Container.main = Container.mainSource.synchronize()
    }
    
    private static func registerYageCapabilities() {
        Capabilities.discovery.register("ActionExecutor") { ActionExecutor() }
        Capabilities.discovery.register("SpritesProvider") { FunnySpritesProvider() }
        Capabilities.discovery.register("MouthOverlayUser") { MouthOverlayUser() }
        Capabilities.discovery.register("EyesOverlayUser") { EyesOverlayUser() }
        Capabilities.discovery.register("TalkingCharacter") { FunnybotTalkingCharacter() }
        Capabilities.discovery.register("Emotional") { Emotional() }
    }
    
    @MainActor
    private static func dependencyContainer() -> Container {
        let configStorage = ConfigStorageServiceImpl(modelContainer: Storage.sharedModelContainer)
        
        let container = Container()
        container.registerEagerSingleton(ConfigStorageService.self, configStorage)
        container.registerEagerSingleton(RuntimeEventsBroker.self, RuntimeEventsBrokerImpl())
        container.registerEagerSingleton(LastOpenTabsUseCase.self, LastOpenTabsUseCaseImpl())
        container.registerEagerSingleton(WindowManager.self, WindowManagerImpl())
        container.registerEagerSingleton(YageConfigBridge.self, YageConfigBridge())
        container.registerEagerSingleton(FilePickerUseCase.self, FilePickerUseCaseImpl())
        container.registerEagerSingleton(PowerManagementUseCase())
        
        container.registerSingleton(WindowSizeService.self) { _ in WindowSizeServiceImpl() }
        container.registerSingleton(ModelContainer.self) { _ in Storage.sharedModelContainer }
        container.registerSingleton(TemporaryFiles.self) { _ in try! TemporaryFiles(name: "it.curzel.funnybot.junk") }
        container.registerSingleton(AppViewModel.self) { _ in AppViewModel.shared }
        container.registerSingleton(AssetsProviderImpl.self) { _ in AssetsProviderImpl() }
        container.registerSingleton(SoundEffectsProvider.self) { _ in SoundEffectsProviderImpl() }
        container.registerSingleton(SoundEffectsProviderImpl.self) { _ in SoundEffectsProviderImpl() }
        container.registerSingleton(DubsStorage.self) { _ in FileBasedDubsStorage() }
        
        container.register(PathsUseCase.self) { _ in PathsUseCaseImpl() }
        container.register(SceneRenderingModeUseCase.self) { _ in SceneRenderingModeUseCaseImpl() }
        container.register(ExportUseCase.self) { _ in ImportExportUseCase() }
        container.register(ImportUseCase.self) { _ in ImportExportUseCase() }
        container.register(CleanerUseCase.self) { _ in ImportExportUseCase() }
        container.register(PromptBuilderUseCase.self) { _ in PromptBuilderUseCaseImpl() }
        container.register(GenerativeAiChatModel.self) { _ in GenerativeAiChatModel() }
        container.register(GenerativeAiWorkingModel.self) { _ in GenerativeAiWorkingModel() }
        container.register(Funnyscript.VoicesProvider.self) { _ in FileBasedDubsStorage() }
        container.register(Funnyscript.CharactersProvider.self) { _ in FunnyscriptCharactersProvider() }
        container.register(EpisodeRendering.self) { _ in EpisodeRenderingImpl() }
        container.register(SceneRendering.self) { _ in SceneRenderingImpl() }
        container.register(FrameRendering.self) { _ in FrameRenderingImpl() }
        container.register(AudioRendering.self) { _ in AudioRenderingImpl() }
        container.register(AudioFormatConverterUseCase.self) { _ in AudioFormatConverterUseCase() }
        container.register(ActionsDispatcher.self) { _ in NameAwareActionsDispatcher() }
        container.register(CameraAgent.self) { _ in CameraAgentImpl() }
        container.register(ScriptDubberUseCase.self) { _ in ScriptDubberUseCaseImpl() }
        container.register(EpisodeDubberUseCase.self) { _ in EpisodeDubberUseCaseImpl() }
        container.register(DubberUseCase.self) { _ in DubberUseCaseImpl() }
        container.register(ScenePositionCoordinatesUseCase.self) { _ in ConfigAwareScenePositionCoordinatesUseCase() }
        container.register(LipSyncUseCase.self) { _ in LipSyncUseCaseImpl() }
        container.register(SecretsStorage.self) { _ in KeychainAccessSecretsStorage() }
        container.register(ApiKeysStorageUseCase.self) { _ in SecureApiKeysStorageUseCase() }
        container.register(GenerativeModelPreferencesUseCase.self) { _ in GenerativeModelPreferencesUseCaseImpl() }
        container.register(CloneEpisodeUseCase.self) { _ in CloneEpisodeUseCaseImpl() }
        container.register(FramesToVideoComposer.self) { _ in FramesToVideoComposerImpl() }
        container.register(VideosToVideoComposer.self) { _ in VideosToVideoComposerImpl() }
        container.register(ShadowingUseCase.self) { _ in ShadowingUseCaseImpl() }
        container.register(ViewScreenshotUseCase.self) { _ in ViewScreenshotUseCaseImpl() }
        container.register(ImageRepresentationsUseCase.self) { _ in ImageRepresentationsUseCaseImpl() }
        container.register(ScriptGenerationUseCase.self) { _ in ScriptGenerationUseCaseImpl() }
        container.register(HeadlessSceneRendering.self) { _ in HeadlessSceneRenderingImpl() }
        container.register(RenderableSceneAssembler.self) { _ in RenderableSceneAssemblerImpl() }
        container.register(Camera.self) { _ in LinearCamera() }
        container.register(VideoPostProcessingUseCase.self) { _ in VideoPostProcessingUseCaseImpl() }
        container.register(SoundEffectsToScriptUseCase.self) { _ in SoundEffectsToScriptUseCaseImpl() }
        container.register(SynthetizedAudioPostProcessingUseCase.self) { _ in CompositeAudioPostProcessing() }
        container.register(AudioVolumeAnalysisUseCase.self) { _ in AudioVolumeAnalysisUseCaseImpl() }
        container.register(CallToActionsToScriptUseCase.self) { _ in CallToActionsToScriptUseCaseImpl() }
        container.register(IndexedDialogsUseCase.self) { _ in IndexedDialogsUseCaseImpl() }
        container.register(ElevenLabsApi.self) { _ in ElevenLabsApi() }
        container.register(ScriptSubtitlesGenerationUseCase.self) { _ in ScriptSubtitlesGenerationUseCaseImpl() }
        container.register(SRTFormattingUseCase.self) { _ in SRTFormattingUseCaseImpl() }
        container.register(AudioSubtitlesGenerationUseCase.self) { _ in SFSpeechBasedAudioSubtitlesGeneration() }
        container.register(AudioFrequencyAnalysisUseCase.self) { _ in AudioFrequencyAnalysisUseCaseImpl() }
        
        container.register(VoiceSynthesizer.self) { _ in
            @Inject var config: ConfigStorageService
            switch config.current.voiceEngine {
            case .elevenLabs: return ElevenLabsSynthesizer()
            case .onDevice: return OnDeviceVoiceSynthesizer()
            }
        }
        
        container.register(VoiceFinder.self){ _ in
            @Inject var config: ConfigStorageService
            switch config.current.voiceEngine {
            case .elevenLabs: return ElevenLabsVoiceFinder()
            case .onDevice: return OnDeviceVoiceFinder()
            }
        }
        
        container.register(Funnyscript.ListAnimationsUseCase.self) { _ in
            @Inject var assets: Funnyscript.AssetsProvider
            return Funnyscript.ListAnimationsUseCase(assets: assets)
        }
        
        container.register(Funnyscript.ListCharactersUseCase.self) { _ in
            @Inject var characters: Funnyscript.CharactersProvider
            return Funnyscript.ListCharactersUseCase(characters: characters)
        }
        
        container.register(Funnybot.AssetsProvider.self) { _ in
            @Inject var assets: AssetsProviderImpl
            return assets
        }
        
        container.register(Funnyscript.AssetsProvider.self) { _ in
            @Inject var assets: AssetsProviderImpl
            return assets
        }
        
        container.register(Funnyscript.SoundEffectsProvider.self) { _ in
            @Inject var soundEffects: SoundEffectsProviderImpl
            return soundEffects
        }
        
        container.register(Funnyscript.Compiler.self) { _ in
            @Inject var assets: Funnyscript.AssetsProvider
            @Inject var config: ConfigStorageService
            @Inject var voices: Funnyscript.VoicesProvider
            @Inject var soundEffects: Funnyscript.SoundEffectsProvider
            
            return Funnyscript.Compiler(
                config: config.current,
                voices: voices,
                assets: assets,
                soundEffects: soundEffects
            )
        }
        
        container.register(Funnyscript.Parser.self) { _ in
            @Inject var config: ConfigStorageService
            @Inject var characters: Funnyscript.CharactersProvider
            return Funnyscript.Parser(config: config.current, charactersProvider: characters)
        }
        return container
    }
}
