//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import SwiftUI
import Combine
import Schwifty
import SwiftUI

struct TextViewWithActions<HeaderItems: View>: View {
    let title: String
    let icon: String?
    let headerItems: () -> HeaderItems
    let value: Binding<String>
    let collapsable: Bool
    
    @State var collapsed: Bool
    
    init(
        title: String,
        icon: String? = nil,
        value: Binding<String>,
        collapsable: Bool = true,
        initiallyCollapsed: Bool = true,
        @ViewBuilder headerItems: @escaping () -> HeaderItems
    ) {
        self.title = title
        self.icon = icon
        self.value = value
        self.collapsable = collapsable
        self.collapsed = collapsable && initiallyCollapsed
        self.headerItems = headerItems
    }
    
    var body: some View {
        VStack(spacing: .sm) {
            HStack(spacing: .md) {
                if collapsable {
                    Button {
                        collapsed = !collapsed
                    } label: {
                        Image(systemName: collapsed ? "chevron.right" : "chevron.down")
                            .foregroundColor(.label)
                            .frame(width: DesignSystem.Buttons.iconWidth)
                    }
                }
                if let icon {
                    Image(systemName: icon).foregroundColor(.label)
                }
                Text(title).lineLimit(2)
                headerItems()
                Spacer()
            }
            if !collapsed {
                DSTextView(value: value)
                    .textFieldBackground()
            }
        }
    }
}
