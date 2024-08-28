import Foundation
import Funnyscript
import Schwifty
import Yage

class RenderableScene: World {
    @Inject private var assets: AssetsProvider
    @Inject private var camera: Camera
    @Inject private var cameraAgent: CameraAgent
    @Inject private var configStorage: ConfigStorageService
    @Inject private var dispatcher: ActionsDispatcher
    @Inject private var dubs: DubsStorage
    @Inject private var soundEffects: SoundEffectsProvider
    
    let sceneId: UUID
    let series: Series
    var duration: TimeInterval!
    
    var config: Config {
        configStorage.current
    }
    
    var cameraViewport: CGRect {
        camera.viewport
    }
    
    private(set) var background: String = "background_default"
    private(set) var audios: [AudioTrack] = []
    private var instructions: [CompiledItem] = []
    
    init(series: Series, sceneId: UUID, size: CGSize, script: CompiledScript) throws {
        @Inject var config: ConfigStorageService
        self.sceneId = sceneId
        self.series = series
        super.init(name: "scene-\(sceneId)", id: sceneId, bounds: CGRect(size: size))
        
        duration = script.duration
        instructions = script.instructions
        
        try loadAudioTracks(from: script)
        spawn(actors: script.actors)
        clearStage()
    }
    
    func entity(matching something: String) -> Entity? {
        dispatcher.entity(in: self, matching: something)
    }
    
    override func update(after timeSinceLastUpdate: TimeInterval) async {
        camera.update(after: timeSinceLastUpdate)
        await super.update(after: timeSinceLastUpdate)
        
        do {
            try await performNecessaryActions(after: timeSinceLastUpdate)
        } catch {
            Logger.debug(name, "Shit happened: \(error)")
        }
    }
    
    private func performNecessaryActions(after timeSinceLastUpdate: TimeInterval) async throws {
        var completedActions: [String] = []
        
        for instruction in instructions {
            guard instruction.startTime <= lastUpdateTime else { continue }
            Logger.debug(name, "Next action: \(instruction)")
            let subject = instruction.instruction.subject
            let action = instruction.instruction.action
            
            if subject == "scene" || subject == "camera" {
                handle(sceneCommand: action)
            } else {
                try await dispatch(action: action, to: subject)
            }
            completedActions.append(instruction.id)
        }
        instructions = instructions.filter { !completedActions.contains($0.id) }
    }
    
    private func handle(sceneCommand: Action) {
        switch sceneCommand {
        case .background(let name): background = name
        case .camera(let view, let smoothly): transitionCamera(to: view, smoothly: smoothly)
        case .clearStage: clearStage()
        case .custom(let foo): foo()
        case .pause: return
        case .shuffle(let hard, let count): moveRandomCharacter(hard: hard, count: count)
        default: Logger.debug(name, "Unsupported action at scene level: \(sceneCommand)")
        }
    }
    
    private func moveRandomCharacter(hard: Bool, count: Int?) {
        let characters = children
            .filter { $0.hasCapability(TalkingCharacter.self) }
            .filter { $0.frame.maxX > 0 && $0.frame.minX < bounds.width }
        let entities = count.let { characters.randomElements(count: $0) } ?? characters
        
        let newPositions: [ScenePosition]
        if entities.count <= ScenePosition.basicPositions.count {
            newPositions = ScenePosition.basicPositions.shuffled().first(entities.count) + []
        } else {
            newPositions = (0..<entities.count).compactMap { _ in ScenePosition.basicPositions.randomElement() }
        }
        
        for (index, entity) in entities.enumerated() {
            let next = newPositions[index]
            if hard {
                entity.place(at: .scenePosition(position: next))
            } else {
                entity.walk(to: next)
            }
        }
    }
    
    private func transitionCamera(to view: CameraViewport, smoothly: Bool) {
        camera.transition(to: cameraFrame(for: view), smoothly: smoothly)
    }
    
    private func cameraFrame(for view: CameraViewport) -> CGRect {
        switch view {
        case .original: CGRect(size: config.videoResolution)
        case .rect(let frame): frame.scaled(config.baseScale)
        case .entities(let ids): cameraFrame(for: ids)
        }
    }
    
    private func cameraFrame(for ids: [String]) -> CGRect {
        let frames = ids
            .compactMap { dispatcher.entity(in: self, matching: $0) }
            .map { $0.frame }
        
        Logger.debug(name, "Moving Camera to", ids.joined(separator: ", "))
        return cameraAgent.viewport(subjects: frames)
    }
    
    private func clearStage() {
        children.forEach {
            $0.set(state: .action(action: .idling, loops: nil))
            $0.set(sprite: nil)
            $0.alpha = 1
            $0.set(direction: .zero)
            $0.uninstall(Seeker.self)
            $0.resetRotation()
            $0.resetFrame()
            $0.resetSpeed()
            $0.resetZIndex()
            
            if $0.isOverlay {
                $0.zIndex = 100
                $0.set(frame: CGRect(origin: .zero, size: config.sceneSize))
            } else {
                $0.place(at: .scenePosition(position: .outsideRightBelow))
            }
        }
        camera.reset()
    }
    
    private func dispatch(action: Action, to subject: String) async throws {
        do {
            try await dispatcher.dispatch(action: action, to: subject, in: self)
        } catch {
            Logger.error(name, "Dispatcher error: \(error)")
        }
    }
    
    @discardableResult
    private func add(_ species: Species) -> Entity {
        let entity = Entity(species: species, in: self)
        entity.set(state: .action(action: .idling, loops: nil))
        
        if species.isOverlay {
            entity.set(frame: CGRect(origin: .zero, size: config.sceneSize))
        } else {
            entity.set(position: .outsideLeft)
        }
        return add(entity)
    }
    
    @discardableResult
    private func add(_ entity: Entity) -> Entity {
        children += [entity]
        return entity
    }
    
    private func remove(_ speciesToRemove: Species) {
        guard let entity = child(species: speciesToRemove) else { return }
        entity.kill()
        children.remove(entity)
    }
    
    private func loadAudioTracks(from script: CompiledScript) throws {
        audios = try script.instructions
            .map { try loadAudioTrack(for: $0) }
            .compactMap { $0 }
    }
    
    private func loadAudioTrack(for compiledInstruction: CompiledItem) throws -> AudioTrack? {
        let scriptInstruction = compiledInstruction.instruction
        
        switch scriptInstruction.action {
        case .talking(let line, _):
            let url = dubs.dub(speaker: scriptInstruction.subject, line: line)
            return AudioTrack(url: url, startTime: compiledInstruction.startTime)
            
        case .animation(let id, let loops):
            guard loops == 1 else { return nil }
            guard let url = soundEffects.soundEffect(id: id) else { return nil }
            return AudioTrack(url: url, startTime: compiledInstruction.startTime)
            
        default: return nil
        }
    }
    
    private func spawn(actors: [String]) {
        dispatcher.entities(for: actors, series: series, scene: self).forEach { add($0) }
        clearStage()
    }
    
    override func schedule(at time: TimeInterval, for species: String, _ foo: @escaping () -> Void) {
        let action = CompiledItem(
            instruction: .init(subject: species, action: .custom(foo: foo)),
            practicalDuration: 0,
            logicalDuration: 0,
            startTime: time
        )
        instructions = (instructions + [action]).sorted {
            $0.startTime < $1.startTime
        }
    }
}

// MARK: - Scene Overlay

extension Entity {
    var isOverlay: Bool {
        species.isOverlay
    }
}

extension Species {
    var isOverlay: Bool {
        id == "overlay" || id == "overlay_video" || id == "overlay_blocking"
    }
}
