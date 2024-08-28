//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import SwiftUI
import Combine
import Schwifty
import SwiftData
import SwiftUI

protocol ExportUseCase {
    @MainActor
    func export() throws -> Data
    
    func nextFileName() -> String
}

protocol ImportUseCase {
    @MainActor
    func `import`(data: Data) throws
}

protocol CleanerUseCase {
    @MainActor
    func deleteAll() throws
}

enum ImportExportError: Error {
    case uncodable(model: String)
}

class ImportExportUseCase: ExportUseCase, ImportUseCase, CleanerUseCase {
    @Inject var modelContainer: ModelContainer
    @Inject var config: ConfigStorageService
    
    func nextFileName() -> String {
        let date = Date().string("yy-MM-dd_HH-mm-ss")
        return "Funnybot_\(date).json"
    }
    
    @MainActor
    func deleteAll() throws {
        let context = modelContainer.mainContext
        try context.delete(model: Config.self)
        try context.delete(model: Series.self)
        try context.delete(model: SeriesCharacter.self)
        try context.delete(model: Episode.self)
        try context.save()
    }
    
    @MainActor
    func export() throws -> Data {
        let context = modelContainer.mainContext
        
        let configs = try context.fetch(FetchDescriptor<Config>())
        let codableConfigs = try configs.map { try CodableConfig(from: $0) }
        
        let series = try context.fetch(FetchDescriptor<Series>())
        let codableSeries = try series
            .map { try CodableSeries(from: $0) }
            .sorted { $0.title < $1.title }
        
        let bundle = ExportBundle(configs: codableConfigs, series: codableSeries)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(bundle)
    }
    
    @MainActor
    func `import`(data: Data) throws {
        let context = modelContainer.mainContext
        let bundle = try JSONDecoder().decode(ExportBundle.self, from: data)
        
        bundle.configs
            .map { $0.asModel() }
            .forEach { context.insert($0) }
        
        for series in bundle.series {
            let seriesModel = series.asModel()
            context.insert(seriesModel)
            
            for character in series.characters {
                let characterModel = character.asModel()
                characterModel.series = seriesModel
                context.insert(characterModel)
            }
            
            for episode in series.episodes {
                let episodeModel = episode.asModel()
                episodeModel.series = seriesModel
                context.insert(episodeModel)
            }
        }
        try context.save()
        
        config.reload()
    }
}

private struct ExportBundle: Codable {
    let configs: [CodableConfig]
    let series: [CodableSeries]
}
