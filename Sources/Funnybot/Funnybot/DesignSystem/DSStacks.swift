//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import SwiftUI

extension VStack {
    init(alignment: HorizontalAlignment, spacing: Spacing, @ViewBuilder content: () -> Content) {
        self.init(
            alignment: alignment,
            spacing: spacing.rawValue,
            content: content
        )
    }

    init(spacing: Spacing, @ViewBuilder content: () -> Content) {
        self.init(
            spacing: spacing.rawValue,
            content: content
        )
    }
}

extension HStack {
    init(alignment: VerticalAlignment, spacing: Spacing, @ViewBuilder content: () -> Content) {
        self.init(
            alignment: alignment,
            spacing: spacing.rawValue,
            content: content
        )
    }

    init(spacing: Spacing, @ViewBuilder content: () -> Content) {
        self.init(
            spacing: spacing.rawValue,
            content: content
        )
    }
}
