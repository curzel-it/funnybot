//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation
import Schwifty
import Swinject

extension Container {
    @discardableResult
    func registerSingleton<Service>(
        _ serviceType: Service.Type,
        name: String? = nil,
        factory: @escaping (Resolver) -> Service
    ) -> ServiceEntry<Service> {
        _register(serviceType, factory: factory, name: name)
            .inObjectScope(.container)
    }
    
    @discardableResult
    func registerEagerSingleton<Service>(_ serviceType: Service.Type, _ instance: Service) -> ServiceEntry<Service> {
        let result = registerSingleton(serviceType) { _ in instance }
        DispatchQueue.main.async {
            @Inject var service: Service.Type
            Logger.debug("Dependencies", "Starting `\(serviceType)`")
        }
        return result
    }
    
    @discardableResult
    func registerEagerSingleton<Service>(_ instance: Service) -> ServiceEntry<Service> {
        registerEagerSingleton(Service.self, instance)
    }
}

extension Container {
    static var main: Resolver!
    static var mainSource: Container!
}

@propertyWrapper
class Inject<Value> {
    private var storage: Value?

    init() {}

    var wrappedValue: Value {
        storage ?? {
            guard let resolver = Container.main else {
                fatalError("Missing call to `Dependencies.setup()`")
            }
            guard let value = resolver.resolve(Value.self) else {
                fatalError("Dependency `\(Value.self)` not found, register it in `Dependencies.setup()`")
            }
            storage = value
            return value
        }()
    }
}
