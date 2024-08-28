//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import SwiftUI
import Combine
import SwiftUI
import Schwifty

protocol WindowManager {}

#if os(macOS)
class WindowManagerImpl: WindowManager {
    @Inject var broker: RuntimeEventsBroker
    @Inject var size: WindowSizeService
    
    private weak var window: NSWindow?
    
    private let kLastFrame = "kLastFrame"
    private let tag = "WindowManagerImpl"
    private var disposables = Set<AnyCancellable>()
    
    init() {
        DispatchQueue.main.async { [weak self] in
            self?.bindWindowAttached()
            self?.bindWindowFrame()
        }
    }
    
    func setup(window: NSWindow) {
        Logger.debug(tag, "Setting up window...")
        size.bindWindow(window)
        window.tabbingMode = .disallowed
        self.window = window
        restoreLastFrameIfPossible()
    }
    
    private func bindWindowAttached() {
        Logger.debug(tag, "Waiting for window to attach...")
        
        broker.events()
            .compactMap {
                if case .windowAttached(let window) = $0 {
                    return window
                }
                return nil
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] window in self?.setup(window: window) }
            .store(in: &disposables)
    }
    
    func bindWindowFrame() {
        size.observeFrame()
            .debounce(for: 0.1, scheduler: DispatchQueue.main)
            .sink { [weak self] frame in
                guard let self else { return }
                Task { @MainActor in
                    self.saveWindowFrame(frame)
                }
            }
            .store(in: &disposables)
    }
    
    private func restoreLastFrameIfPossible() {
        guard let frame = storedFrame() else { return }
        guard let screen = Screen.main else { return }
        guard screen.frame.contains(rect: frame) else { return }
        Logger.debug(tag, "Restored previous window frame:", frame.description)
        window?.setFrame(frame, display: true)
    }
    
    @MainActor
    func saveWindowFrame(_ frame: CGRect) {
        Logger.debug(tag, "Saved latest window frame:", frame.description)
        store(frame: frame)
    }
    
    private func storedFrame() -> CGRect? {
        let values = UserDefaults.standard.array(forKey: kLastFrame) as? [CGFloat]
        guard let values, values.count == 4 else { return nil }
        return CGRect(x: values[0], y: values[1], width: values[2], height: values[3])
    }
    
    private func store(frame: CGRect) {
        let values = [frame.origin.x, frame.origin.y, frame.width, frame.height]
        UserDefaults.standard.set(values, forKey: kLastFrame)
    }
}
#else
class WindowManagerImpl: WindowManager {
    private let tag = "WindowManagerImpl"
    
    init() {
        Logger.debug(tag, "Unsupported on iOS")
    }
}
#endif
