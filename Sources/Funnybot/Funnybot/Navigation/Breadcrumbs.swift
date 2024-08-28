//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation
import Schwifty
import SwiftUI

struct BreadcrumbsView: View {
    @EnvironmentObject private var viewModel: TabViewModel
    
    var body: some View {
        HStack(spacing: .sm) {
            ForEach(viewModel.navigationHistory) {
                let isSelected = viewModel.isSelected($0)
                BreadcrumbView(item: $0, isSelected: isSelected)
                
                if !isSelected {
                    Image(systemName: "chevron.right")
                        .font(.headline)
                }
            }
        }
    }
}

private struct BreadcrumbView: View {
    @EnvironmentObject private var viewModel: TabViewModel
    
    let item: NavigationDestination
    let isSelected: Bool
    
    var body: some View {
        Button {
            viewModel.navigate(to: item)
        } label: {
            Text(item.title)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .font(isSelected ? .body.bold() : .body)
                .foregroundColor(isSelected ? .accentColor : .label)
        }
        .buttonStyle(.plain)
    }
}
