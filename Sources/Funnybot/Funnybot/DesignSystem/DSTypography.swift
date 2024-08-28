//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation
import SwiftUI
import Schwifty

extension Text {
    func pageTitle() -> some View {
        textAlign(.leading).pageTitleFont()
    }
    
    func sectionTitle() -> some View {
        textAlign(.leading).sectionTitleFont()
    }
    
    func cardTitle() -> some View {
        cardTitleFont()
    }
}

extension View {
    func pageTitleFont() -> some View {
        font(.title.bold())
    }
    
    func sectionTitleFont() -> some View {
        font(.title2.bold())
    }
    
    func cardTitleFont() -> some View {
        font(.title3.bold())
    }
    
    func monospaced() -> some View {
        font(.system(.body, design: .monospaced))
            .lineSpacing(8)
    }
}
