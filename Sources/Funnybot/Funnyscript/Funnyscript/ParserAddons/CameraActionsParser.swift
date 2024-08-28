//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation

class CameraActionsParser: ParserAddon {
    let usingAutoCamera: Bool
    
    init(usingAutoCamera: Bool) {
        self.usingAutoCamera = usingAutoCamera
    }
    
    func instructions(from originalText: String, subject: String) async throws -> [Instruction]? {
        if let action = cameraResetAction(from: originalText) {
            return [Instruction(subject: subject, action: action)]
        }
        if let action = cameraViewAction(from: originalText) {
            return [Instruction(subject: subject, action: action)]
        }
        return nil
    }

    private func cameraResetAction(from actionText: String) -> Action? {
        guard actionText == "reset" else { return nil }
        return .camera(view: .original, smoothly: false)
    }
    
    private func cameraViewAction(from actionText: String) -> Action? {
        guard actionText.hasPrefix("view") || actionText.hasPrefix("transition view")  else { return nil }
        guard let viewportString = actionText.lastWord() else { return nil }
        
        let smoothly = actionText.contains("transition")
        let view = CameraViewport.from(viewportString)
        return .camera(view: view, smoothly: smoothly)
    }
    
    private func viewport(from viewportString: String) -> CGRect? {
        let tokens = viewportString
            .components(separatedBy: "x")
            .flatMap { $0.components(separatedBy: "+") }
            .compactMap { Float($0) }
            .map { CGFloat($0) }
        
        guard tokens.count == 4 else { return nil }
        
        return CGRect(
            x: tokens[2],
            y: tokens[3],
            width: tokens[0],
            height: tokens[1]
        )
    }
}
