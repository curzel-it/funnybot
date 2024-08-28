import Foundation
import Funnyscript
import Yage

protocol ActionsDispatcher {
    func entity(in world: RenderableScene, matching something: String) -> Entity?
    func entities(for actors: [String], series: Series, scene: RenderableScene) -> [Entity]
    func entity(for actor: String, series: Series?, scene: RenderableScene?) -> Entity
    func entity(for actor: String, series: Series?) -> Entity
    func dispatch(action: Action, to subject: String, in world: RenderableScene) async throws
}

enum ActionsDispatcherError: Error {
    case subjectNotFound(id: String)
}

class NameAwareActionsDispatcher: ActionsDispatcher {  
    private let extraCapabilities: [Capability.Type] = [
        FunnySpritesProvider.self,
        OpacityTransitioner.self
    ]
    
    func entity(in world: RenderableScene, matching something: String) -> Entity? {
        let entityBySpecies = world.child(species: something)
        let entityByName = child(named: something, in: world)
        return entityBySpecies ?? entityByName
    }
    
    func entity(for actor: String, series: Series?, scene: RenderableScene?) -> Entity {
        let world = scene ?? World(name: "", id: UUID(), bounds: .zero)
        let species = species(for: actor, in: series)
        let entity = Entity(species: species, in: world)
        extraCapabilities.forEach { entity.install($0.init()) }
        return entity
    }
    
    func entity(for actor: String, series: Series?) -> Entity {
        entity(for: actor, series: series, scene: nil)
    }
    
    func entities(for actors: [String], series: Series, scene: RenderableScene) -> [Entity] {
        actors.map { entity(for: $0, series: series, scene: scene) }
    }
    
    func dispatch(action: Action, to subject: String, in world: RenderableScene) async throws {
        guard let entity = entity(in: world, matching: subject) else {
            throw ActionsDispatcherError.subjectNotFound(id: subject)
        }
        try await entity.apply(action)
    }
    
    private func species(for id: String, in series: Series?) -> Species {
        let allCharacters = series?.characters ?? []
        let allSpecies = allCharacters.map { $0.species() }
        
        let matches = [
            allSpecies.first { $0.id == id },
            allSpecies.first { $0.nickname == id },
            allSpecies.first { $0.nickname == id.lowercased() },
            allSpecies.first { $0.nickname == id.replacingOccurrences(of: " ", with: "") },
        ]
        return matches
            .compactMap { $0 }
            .first ?? Species(id: id)
    }
    
    private func child(named name: String, in world: World) -> Entity? {
        world.children.first { character in
            false ||
            character.species.nickname == name ||
            character.species.nickname == name.lowercased() ||
            character.species.nickname == name.replacingOccurrences(of: " ", with: "")
        }
    }
}
