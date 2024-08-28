//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import SwiftUI
import Foundation
import Combine

protocol WindowSizeService {
    func bindWindow(_ window: NSWindow)
    func currentFrame() -> CGRect
    func observeFrame() -> AnyPublisher<CGRect, Never>
}

extension WindowSizeService {
    func currentSize() -> CGSize {
        currentFrame().size
    }
    
    func observeSize() -> AnyPublisher<CGSize, Never> {
        observeFrame()
            .map { $0.size }
            .eraseToAnyPublisher()
    }
    
    func currentPosition() -> CGPoint {
        currentFrame().origin
    }
    
    func observePosition() -> AnyPublisher<CGPoint, Never> {
        observeFrame()
            .map { $0.origin }
            .eraseToAnyPublisher()
    }
}

class WindowSizeServiceImpl: NSObject, NSWindowDelegate, WindowSizeService {
    private var frameSubject = CurrentValueSubject<CGRect, Never>(.zero)
    private weak var window: NSWindow?
    
    func bindWindow(_ window: NSWindow) {
        frameSubject.send(window.frame)
        window.delegate = self
        self.window = window
    }
    
    func windowDidMove(_: Notification) {
        sendFrameUpdate()
    }
    
    func windowDidResize(_ notification: Notification) {
        sendFrameUpdate()
    }
    
    private func sendFrameUpdate() {
        guard let frame = window?.frame else { return }
        frameSubject.send(frame)
    }
    
    func currentFrame() -> CGRect {
        frameSubject.value
    }
    
    func observeFrame() -> AnyPublisher<CGRect, Never> {
        frameSubject
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
