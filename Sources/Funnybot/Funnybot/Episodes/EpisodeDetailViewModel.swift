//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation
import Combine
import Schwifty
import SwiftUI
import SwiftData

class EpisodeDetailViewModel: ObservableObject {
    @Published var number: String
    @Published var title: String
    @Published var concept: String
    @Published var script: String
    
    @Inject private var app: AppViewModel
    @Inject private var cloneEpisode: CloneEpisodeUseCase
    @Inject private var paths: PathsUseCase
    @Inject private var modelContainer: ModelContainer
    
    weak var tab: TabViewModel?
    let episode: Episode
    private var disposables = Set<AnyCancellable>()
        
    var canRender: Bool {
        episode.hasScript
    }
    
    var hasVideos: Bool {
        let folder = paths.videosFolder(for: episode)
        return FileManager.default.fileExists(at: folder)
    }
    
    init(episode: Episode) {
        self.episode = episode
        number = "\(episode.number)"
        script = episode.script
        title = episode.title
        concept = episode.concept
        bindAutoSave()
    }
    
    private func bindAutoSave() {
        objectWillChange
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                Task { @MainActor in
                    self.save()
                }
            }
            .store(in: &disposables)
    }
    
    @MainActor
    func showRendering() {
        tab?.navigate(to: .rendering(episode: episode))
    }
    
    @MainActor
    func generateScript() {
        tab?.navigate(to: .episodeGroupChat(episode: episode))
    }
        
    @MainActor
    func delete(goBack: Bool = true) {
        episode.modelContext?.delete(episode)
        try? episode.modelContext?.save()
        if goBack {
            tab?.navigateBack()
        }
    }
    
    func showDubs() {
        Task { @MainActor in
            tab?.navigate(to: .dubber(episode: episode))
        }
    }
    
    @MainActor
    func clone() {
        let clone = cloneEpisode.clone(episode)
        modelContainer.mainContext.insert(clone)
        try? modelContainer.mainContext.save()
        tab?.navigate(to: .episode(episode: clone))
    }
    
    @MainActor
    func save() {
        episode.title = title
        episode.concept = concept
        episode.script = script
        episode.number = Int(number) ?? episode.number
        
        let context = modelContainer.mainContext
        context.insert(episode)
        try? context.save()
    }
    
    @MainActor
    func onDisappear() {
        if episode.modelContext == nil {
            delete(goBack: false)
        }
    }
}
