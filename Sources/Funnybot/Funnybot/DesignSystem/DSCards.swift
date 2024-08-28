//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Combine
import Schwifty
import SwiftUI

struct CardsGrid<T: Identifiable, ItemView: View>: View {
    let items: [T]
    let minColumnWidth: CGFloat
    let maxColumnWidth: CGFloat
    
    @ViewBuilder let render: (T) -> ItemView
    
    init(items: [T], minColumnWidth: CGFloat = 140, maxColumnWidth: CGFloat = 800, @ViewBuilder render: @escaping (T) -> ItemView) {
        self.render = render
        self.items = items
        self.minColumnWidth = minColumnWidth
        self.maxColumnWidth = maxColumnWidth
    }
    
    var body: some View {
        LazyVGrid(
            columns: [.init(.adaptive(minimum: minColumnWidth, maximum: maxColumnWidth), spacing: Spacing.md.rawValue)],
            alignment: .leading,
            spacing: Spacing.md.rawValue
        ) {
            ForEach(items) {
                render($0)
            }
        }
    }
}

extension View {
    func card() -> some View {
        self
            .padding(.md)
            .aspectRatio(1.5, contentMode: .fill)
            .dimBackground()
            .quickCornerRadius()
            .shadow(radius: 10)
    }
}
