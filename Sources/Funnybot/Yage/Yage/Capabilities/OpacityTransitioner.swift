import Foundation

public class OpacityTransitioner: Capability {
    private let step: CGFloat = 0.2
    
    public func transition(to value: CGFloat, smoothly: Bool) {
        if !smoothly {
            subject?.alpha = value
        } else {
            fade(to: value)
        }
    }
    
    private func fade(to value: CGFloat) {
        guard let subject, let world = subject.world else { return }
        
        if value == 1 { subject.alpha = 0 }
        if value == 0 { subject.alpha = 1 }
        
        let diff = value - subject.alpha
        let numberOfSteps = abs(Int(ceil(diff/step)))
        let initialValue = subject.alpha
        let sign: CGFloat = value < initialValue ? -1 : 1
        
        (1...numberOfSteps).forEach { i in
            let delay = subject.lastUpdateTime + TimeInterval(i) * Config.shared.frameTime
            let delta = sign * CGFloat(i) * step
            let alpha = max(min(initialValue + delta, 1), 0)
            
            world.schedule(at: delay, for: subject.species.id) {
                subject.alpha = alpha
            }
        }
    }
}
