//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Combine
import Foundation
import Schwifty
import SwiftUI
import SwiftData

class SeriesDetailViewModel: ObservableObject {
    weak var tab: TabViewModel?
    let series: Series
    
    @Inject private var modelContainer: ModelContainer
    
    private var disposables = Set<AnyCancellable>()
    
    var charactersTitle: String {
        let count = series.characters?.count ?? 0
        return switch count {
        case 0: "Add the first character"
        case 1: "See 1 Character"
        default: "See \(count) Characters"
        }
    }
    
    var episodesTitle: String {
        let count = series.episodes?.count ?? 0
        return switch count {
        case 0: "Create the first episode!"
        case 1: "See 1 Episode"
        default: "See \(count) Episodes"
        }
    }
    
    var canShowEpisodes: Bool {
        true
    }
    
    @Published var title: String
    @Published var about: String
    @Published var scriptInit: String
    
    init(series: Series) {
        self.series = series
        title = series.title
        about = series.about
        scriptInit = series.scriptInit
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
    func seeCharacters() {
        tab?.navigate(to: .characters(series: series))
    }

    @MainActor
    func delete(goBack: Bool = true) {
        series.modelContext?.delete(series)
        try? series.modelContext?.save()
        if goBack {
            tab?.navigateBack()
        }
    }
    
    @MainActor
    func save() {
        series.title = title
        series.about = about
        series.scriptInit = scriptInit
        
        let context = modelContainer.mainContext
        context.insert(series)
        try? context.save()
    }
    
    @MainActor
    func onDisappear() {
        if series.modelContext == nil {
            delete(goBack: false)
        }
    }
    
    @MainActor
    func newEpisode() {
        let currentMax = series.episodes?.map { $0.number }.max() ?? 0
        let nextNumber = currentMax + 1
        let episode = Episode(series: series, title: "New Episode", number: nextNumber)
        modelContainer.mainContext.insert(episode)
        try? modelContainer.mainContext.save()
        tab?.navigate(to: .episode(episode: episode))
    }
}
