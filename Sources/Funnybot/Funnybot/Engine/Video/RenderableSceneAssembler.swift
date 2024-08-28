//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation
import Funnyscript
import Schwifty

protocol RenderableSceneAssembler {
    func scene(for episode: Episode) async throws -> RenderableScene
}

class RenderableSceneAssemblerImpl: RenderableSceneAssembler {
    @Inject private var config: ConfigStorageService
    @Inject private var parser: Funnyscript.Parser
    @Inject private var compiler: Funnyscript.Compiler
    
    private let tag = "RenderableSceneAssembler"
    
    func scene(for episode: Episode) async throws -> RenderableScene {
        let script = episode.fullScript
        let instructions = try await parser.instructions(from: script)
        let compiledInstructions = try await compiler.compile(instructions: instructions)
        
        return try RenderableScene(
            series: try episode.series.unwrap(),
            sceneId: episode.id,
            size: config.current.sceneSize,
            script: compiledInstructions
        ) 
    }
}
