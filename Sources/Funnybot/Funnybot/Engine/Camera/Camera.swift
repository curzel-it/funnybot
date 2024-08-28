import Foundation
import Schwifty

protocol Camera {
    var viewport: CGRect { get }
    
    func reset()
    func transition(to destination: CGRect, smoothly: Bool)
    func update(after timeSinceLastUpdate: TimeInterval)
}

typealias RectDiff = (x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat)
