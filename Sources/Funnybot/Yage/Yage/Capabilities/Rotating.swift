//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import SwiftUI

public class Rotating: Capability {
    public private(set) var rotation = Rotation()
    
    public var zAngle: CGFloat {
        get { rotation.zAngle }
        set { rotation.zAngle = newValue }
    }
    
    public var isFlippedVertically: Bool {
        get { rotation.isFlippedVertically }
        set { rotation.isFlippedVertically = newValue }
    }
    
    public var isFlippedHorizontally: Bool {
        get { rotation.isFlippedHorizontally }
        set { rotation.isFlippedHorizontally = newValue }
    }
    
    public required init() {
        super.init()
    }
    
    public override func install(on subject: Entity) {
        super.install(on: subject)
        isEnabled = false
    }
    
    public func reset() {
        rotation = .zero
    }
}

public struct Rotation {
    public static let zero = Rotation()
    
    public var zAngle: CGFloat = 0
    public var isFlippedVertically: Bool = false
    public var isFlippedHorizontally: Bool = false
    
    public init() {
        self.init(zAngle: 0, isFlippedVertically: false, isFlippedHorizontally: false)
    }
    
    public init(zAngle: CGFloat, isFlippedVertically: Bool, isFlippedHorizontally: Bool) {
        self.zAngle = zAngle
        self.isFlippedVertically = isFlippedVertically
        self.isFlippedHorizontally = isFlippedHorizontally
    }
}

public extension Entity {
    var rotation: Rotating? {
        capability(for: Rotating.self)
    }
}
