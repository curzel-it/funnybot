//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Schwifty
import SwiftUI

open class Capability {
    public weak var subject: Entity?
    public var isEnabled: Bool = true

    private(set) var lastUpdateTime: TimeInterval = 0
    
    public private(set) lazy var tag: String = {
        let name = String(describing: type(of: self))
        let id = subject?.id ?? "n/a"
        return "\(id)][\(name)"
    }()
    
    public required init() {}

    open func install(on subject: Entity) {
        Logger.log(subject.id, "Installing", String(describing: self))
        self.subject = subject
    }
    
    open func update(after timeSinceLastUpdate: TimeInterval) async {
        if isEnabled {
            await doUpdate(after: timeSinceLastUpdate)
        }
        lastUpdateTime += timeSinceLastUpdate
    }
    
    open func doUpdate(after time: TimeInterval) async {
        // ...
    }

    open func kill(autoremove: Bool = true) {
        if autoremove {
            subject?.capabilities.removeAll { $0.tag == tag }
        }
        subject = nil
        isEnabled = false
    }
}

public extension Entity {
    func install(_ capability: Capability) {
        capability.install(on: self)
        capabilities.append(capability)
    }
}
