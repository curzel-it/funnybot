//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation
import SwiftData

@Model
final class Series: IdentifiableRecord {
    let id = UUID()
    var title: String = ""
    var about: String = ""
    var style: String = ""
    var scriptInit: String = ""
    
    var characters: [SeriesCharacter]? = []
    var episodes: [Episode]? = []
    
    init(title: String, about: String, style: String) {
        self.title = title
        self.about = about
        self.scriptInit = ""
    }
    
    init() {
        // ...
    }
}

extension Series: Equatable {
    static func ==(lhs: Series, rhs: Series) -> Bool {
        lhs.id == rhs.id
    }
}

