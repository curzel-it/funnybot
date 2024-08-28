//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import SwiftUI
import Combine
import Schwifty

enum RuntimeEvent: Equatable, CustomStringConvertible {
    case loading
    case appLaunched
    case appWillTerminate
    case windowAttached(window: NSWindow?)
    
    var eventName: String {
        switch self {
        case .loading: "loading"
        case .appLaunched: "appLaunched"
        case .appWillTerminate: "appWillTerminate"
        case .windowAttached: "windowAttached"
        }
    }
    
    var description: String {
        eventName
    }
    
    static func == (lhs: RuntimeEvent, rhs: RuntimeEvent) -> Bool {
        lhs.eventName == rhs.eventName
    }
}

protocol RuntimeEventsBroker {
    func events() -> AnyPublisher<RuntimeEvent, Never>
    func send(_ event: RuntimeEvent)
}

class RuntimeEventsBrokerImpl: RuntimeEventsBroker {
    private let eventsSubject = CurrentValueSubject<RuntimeEvent, Never>(.loading)
    
    private let tag = "RuntimeEventsBroker"
    
    init() {
        Logger.debug(tag, "Launched")
    }
    
    func events() -> AnyPublisher<RuntimeEvent, Never> {
        eventsSubject.eraseToAnyPublisher()
    }

    func send(_ event: RuntimeEvent) {
        eventsSubject.send(event)
        Logger.debug(tag, "Received: \(event)")
    }
}
