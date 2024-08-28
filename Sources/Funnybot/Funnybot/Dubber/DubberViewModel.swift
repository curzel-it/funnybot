//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation
import Funnyscript
import Combine
import SwiftUI
import SwiftData

class DubberViewModel: Identifiable, ObservableObject {
    @Inject private var appViewModel: AppViewModel
    @Inject private var dubber: DubberUseCase
    @Inject private var modelContainer: ModelContainer
    @Inject private var voiceFinder: VoiceFinder
    
    weak var tab: TabViewModel?
    private let episode: Episode
    
    @Published var dubs: [DialogLine] = []
    @Published var progress: Float?
    
    init(episode: Episode) {
        self.episode = episode
        Task {
            await reloadDubs()
        }
    }
    
    func listVoices() {
        Task {
            let voices = await voiceFinder.listVoices()
            let text = voices.map { "* \($0.name) -> \($0.id)" }.joined(separator: "\n")
            appViewModel.message(text: text)
        }
    }
    
    func reloadDubs() async {
        let newDubs = await dubber.dialogLines(from: episode.script)
        Task { @MainActor in
            dubs = newDubs
        }
    }
    
    func generateDub(for line: DialogLine) {
        Task {
            do {
                dubber.deleteDub(for: line)
                try await dubber.generateDub(for: line, episode: episode)
                await reloadDubs()
            } catch {
                appViewModel.message(text: "Error: \(error)")
            }
        }
    }
    
    func generateDubs() {
        Task {
            do {
                try await dubber.generateDubs(for: episode) { [weak self] progress in
                    self?.set(progress: progress)
                }
                await reloadDubs()
            } catch {
                appViewModel.message(text: "Error: \(error)")
            }
            set(progress: nil)
        }
    }
    
    func set(progress: Float?) {
        Task { @MainActor in
            self.progress = progress
        }
    }
    
    func startRecording(for line: DialogLine) {
        // ...
    }
    
    func stopRecording(for line: DialogLine) {
        // ...
    }
    
    func pickFile(for line: DialogLine) {
        // ...
    }
    
    func deleteDub(for line: DialogLine) {
        dubber.deleteDub(for: line)
    }
}
