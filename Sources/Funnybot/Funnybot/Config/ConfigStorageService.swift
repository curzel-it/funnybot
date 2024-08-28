import Combine
import SwiftData
import Schwifty
import SwiftUI

protocol ConfigStorageService {
    var current: Config { get }
    
    func observe() -> AnyPublisher<Config, Never>
    
    @MainActor
    func delete(config: Config)
    
    @MainActor
    func setCurrent(config: Config)
    
    @MainActor
    func all() -> [Config]
    
    @MainActor
    func reload()
    
    @MainActor
    func save(config: Config)
}

class ConfigStorageServiceImpl: ConfigStorageService {
    private var modelContainer: ModelContainer
    private var subject = CurrentValueSubject<Config, Never>(Config())
    
    private(set) var current: Config
    
    private let kCurrentConfig = "kCurrentConfig"
    
    @MainActor
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        
        if let id = UUID(uuidString: UserDefaults.standard.string(forKey: kCurrentConfig) ?? "") {
            let description = FetchDescriptor<Config>(
                predicate: #Predicate { $0.id == id }
            )
            if let config = try? modelContainer.mainContext.fetch(description).first {
                current = config
                subject.send(current)
                return
            }
        }
                
        if let anyConfig = try? modelContainer.mainContext.fetch(FetchDescriptor<Config>()).first {
            current = anyConfig
        } else {
            let initialConfig = Config()
            current = initialConfig
            save(config: initialConfig)
        }
        subject.send(current)
    }
    
    func observe() -> AnyPublisher<Config, Never> {
        subject.removeDuplicates().eraseToAnyPublisher()
    }
    
    @MainActor
    func delete(config: Config) {
        modelContainer.mainContext.delete(config)
        try? modelContainer.mainContext.save()
    }
    
    @MainActor
    func setCurrent(config: Config) {
        UserDefaults.standard.set(config.id.uuidString, forKey: kCurrentConfig)
        current = config
        subject.send(current)
    }
    
    @MainActor
    func all() -> [Config] {
        let results = try? modelContainer.mainContext.fetch(FetchDescriptor<Config>())
        return results ?? []
    }
    
    @MainActor
    func reload() {
        if let storedConfig = try? modelContainer.mainContext.fetch(FetchDescriptor<Config>()).first {
            current = storedConfig
        } else {
            let initialConfig = Config()
            current = initialConfig
            save(config: initialConfig)
        }
    }
    
    @MainActor
    func save() {
        save(config: current)
    }
    
    @MainActor
    func save(config: Config) {
        let context = modelContainer.mainContext
        context.insert(config)
        try? context.save()
        current = config
    }
}
