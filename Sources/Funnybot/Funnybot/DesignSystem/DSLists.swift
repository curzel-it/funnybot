//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation
import SwiftUI
import Schwifty

struct DSList<Item: Identifiable, ItemView: View>: View {
    let items: [Item]
    let render: (Item) -> ItemView
    let scrollable: Bool
    
    init(_ items: [Item], scrollable: Bool = true, @ViewBuilder render: @escaping (Item) -> ItemView) {
        self.items = items
        self.render = render
        self.scrollable = scrollable
    }
    
    var body: some View {
        VStack(spacing: .zero) {
            ForEach(items) {
                render($0).listItem()
            }
        }
        .padding(.horizontal, scrollable ? .md : .zero)
        .scrollable(scrollable)
    }
}

private extension View {
    func scrollable(_ enabled: Bool) -> some View {
        if enabled {
            ScrollView {
                self
            }
            .eraseToAnyView()
        } else {
            self.eraseToAnyView()
        }
    }
    
    func listItem() -> some View {
        VStack(spacing: .zero) {
            self.positioned(.leading)
                .frame(minHeight: DesignSystem.Lists.itemHeight)
                .contentShape(Rectangle())
            Rectangle()
                .fill(Color.listItemsSeparator)
                .frame(height: 1)
        }
    }
}
