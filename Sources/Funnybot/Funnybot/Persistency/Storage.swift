//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation
import SwiftData

class Storage {
    static var sharedModelContainer: ModelContainer = {
        let schema = Schema(
            [
                Config.self,
                Series.self,
                SeriesCharacter.self,
                Episode.self
            ],
            version: .init(1, 0, 1)
        )
        let modelConfiguration = ModelConfiguration("4", schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    private var modelContainer: ModelContainer {
        Storage.sharedModelContainer
    }
    
    @MainActor
    func series(byId id: UUID) throws -> Series {
        let description = FetchDescriptor<Series>(predicate: #Predicate { $0.id == id })
        return try modelContainer.mainContext.fetch(description).first.unwrap()
    }
    
    @MainActor
    func character(byId id: UUID) throws -> SeriesCharacter {
        let description = FetchDescriptor<SeriesCharacter>(predicate: #Predicate { $0.id == id })
        return try modelContainer.mainContext.fetch(description).first.unwrap()
    }
    
    @MainActor
    func episode(byId id: UUID) throws -> Episode {
        let description = FetchDescriptor<Episode>(predicate: #Predicate { $0.id == id })
        return try modelContainer.mainContext.fetch(description).first.unwrap()
    }
}

