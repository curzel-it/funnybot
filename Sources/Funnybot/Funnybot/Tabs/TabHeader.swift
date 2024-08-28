//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation
import SwiftUI

struct TabHeader: View {
    @EnvironmentObject var tabs: TabsContainerViewModel
    
    @StateObject var viewModel: TabViewModel
    let isSelected: Bool
    
    var backgroundColor: Color {
        isSelected ? Color.background : Color.tertiaryBackground
    }
    
    var body: some View {
        HStack(spacing: .sm) {
            if isSelected {
                BreadcrumbsView()
            } else {
                Text(viewModel.current.title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .frame(height: DesignSystem.Tabs.headerHeight)
                    .onTapGesture { tabs.select(viewModel) }
            }
            Button {
                tabs.close(viewModel)
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(.label)
            }
            .buttonStyle(.plain)
        }
        .frame(height: DesignSystem.Tabs.headerHeight)
        .background(backgroundColor)
        .padding(.horizontal, DesignSystem.Tabs.headerSlopeWidth)
        .background(
            HStack(spacing: .zero) {
                Image("tab_bend")
                    .colorMultiply(backgroundColor)
                Spacer()
                Image("tab_bend")
                    .colorMultiply(backgroundColor)
                    .scaleEffect(x: -1, anchor: .center)
            }
            .shadow(color: .white.opacity(0.2), radius: 1)
        )
        .padding(.bottom, DesignSystem.Tabs.headerHeightBottomPadding)
        .frame(height: DesignSystem.Tabs.headerHeight)
        .environmentObject(viewModel)
    }
}
