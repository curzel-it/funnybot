//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation
import Schwifty
import SwiftData
import Yage

class BodyPartOverlayUser: OverlayCapability {
    private(set) var character: SeriesCharacter?
    
    override func install(on subject: Entity) {
        super.install(on: subject)
        Task { @MainActor in
            linkCharacter()
        }
    }
    
    override func doUpdate(after time: TimeInterval) async {
        await super.doUpdate(after: time)
        updatePosition()
        await updateAnimation()
    }
    
    func updateAnimation() async {
        let path = nextAnimation()
        overlay?.set(state: .action(action: .init(id: path), loops: nil))
        await overlay?.capability(for: AnimatedSprite.self)?.update(after: 0)
    }
    
    private func updatePosition() {
        guard let subject else { return }
        guard let animation = currentAnimation() else { return }
        guard let reference = overlayReferenceFrame(for: animation) else { return }
        let frame = overlayFrame(
            reference: reference,
            subjectFrame: subject.frame,
            isFlippedDirection: subject.direction.isLateral && subject.direction.dx < 0
        )
        overlay?.set(direction: subject.direction)
        overlay?.set(frame: frame)
    }
    
    func nextAnimation() -> String {
        fatalError("Implement in your subclass")
    }
    
    func overlayReferenceFrame(for animation: String) -> CGRect? {
        fatalError("Implement in your subclass")
    }
    
    private func overlayFrame(reference: CGRect, subjectFrame: CGRect, isFlippedDirection: Bool) -> CGRect {
        let width = reference.width * subjectFrame.width
        let height = reference.height * subjectFrame.height
        let x = reference.origin.x * subjectFrame.width
        let y = reference.origin.y * subjectFrame.height
        
        let actualX: CGFloat
        if isFlippedDirection {
            actualX = subjectFrame.origin.x + subjectFrame.width - x - width
        } else {
            actualX = subjectFrame.origin.x + x
        }
        
        return CGRect(
            x: actualX,
            y: subjectFrame.origin.y + subjectFrame.height - y - height,
            width: width,
            height: height
        )
    }
    
    private func currentAnimation() -> String? {
        guard let subject else { return nil }
        
        switch subject.state {
        case .action(let animation, _):
            if animation.id == "idling" {
                return subject.sprite?
                    .components(separatedBy: "_")
                    .byRemovingFirst()
                    .flatMap { $0.components(separatedBy: "-") }
                    .byRemovingLast()
                    .joined(separator: "_")
            } else {
                return animation.id
            }
        case .move: return "lateral"
        }
    }
    
    @MainActor
    private func linkCharacter() {
        @Inject var modelContainer: ModelContainer
        let species = subject?.species.id ?? ""
        let descriptor = FetchDescriptor<SeriesCharacter>(
            predicate: #Predicate { $0.path == species }
        )
        character = try? modelContainer.mainContext.fetch(descriptor).first
    }
}
