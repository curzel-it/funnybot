//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation
import SwiftData

@Model
final class Episode: IdentifiableRecord {
    let id = UUID()
    var title: String = ""
    var number: Int = 0
    var concept: String = ""
    var script: String = ""
    
    @Relationship(inverse: \Series.episodes) var series: Series?
    
    var hasConcept: Bool {
        !concept.isBlank
    }
    
    var hasScript: Bool {
        !script.isBlank
    }
    
    var fullScript: String {
        "\(series?.scriptInit ?? "")\n\(script)"
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    init(series: Series, title: String, number: Int) {
        self.title = title
        self.number = number
        self.concept = ""
        self.script = ""
        self.series = series
    }
    
    init() {
        // ...
    }
}

extension Episode: Comparable {
    static func < (lhs: Episode, rhs: Episode) -> Bool {
        if lhs.number != rhs.number {
            lhs.number > rhs.number
        } else {
            lhs.title < rhs.title
        }
    }
}
