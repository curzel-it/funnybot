//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation
import SwiftUI
import SwiftData
import Schwifty

class SeriesEpisodesViewModel: ObservableObject {
    let series: Series
    
    @Published var episodes: [Episode] = []
    @Published var collapsed: Bool = false
    
    weak var tab: TabViewModel?
    
    var title: String {
        "Episodes (\(series.episodes?.count ?? 0))"
    }
    
    var collapseIcon: String {
        collapsed ? "chevron.right" : "chevron.down"
    }
 
    init(series: Series) {
        self.series = series
        episodes = series.episodes?.sorted() ?? []
    }
    
    @MainActor
    func toggleCollapse() {
        collapsed.toggle()
    }
}
