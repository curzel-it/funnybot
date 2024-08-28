//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import SwiftUI

struct TabsContainer: View {
    @StateObject var viewModel: TabsContainerViewModel
        
    var body: some View {
        VStack(spacing: .zero) {
            Header()
            Tabs()
        }
        .background(Color.secondaryBackground)
        .environmentObject(viewModel)
    }
}

private struct Tabs: View {
    @EnvironmentObject var viewModel: TabsContainerViewModel
    
    var body: some View {
        ForEach(viewModel.tabs) {
            if viewModel.isSelected($0) {
                TabView(viewModel: $0)
                    .background(Color.background)
            }
        }
    }
}

private struct Header: View {
    @EnvironmentObject var viewModel: TabsContainerViewModel

    var body: some View {
        HStack(spacing: .zero) {
            if viewModel.index != 0 {
                Text("\(viewModel.index))").font(.headline)
                    .padding(.leading, .sm)
            }
            HStack(spacing: .sm) {
                ForEach(viewModel.tabs) { tab in
                    let isSelected = viewModel.isSelected(tab)
                    // let padding = viewModel.leadingPadding(forHeaderOf: tab)
                    
                    TabHeader(viewModel: tab, isSelected: isSelected)
                        //.padding(.leading, padding)
                }
                Button {
                    viewModel.newTab()
                } label: {
                    HStack(spacing: .zero) {
                        Text("New tab")
                        Image(systemName: "plus")
                            .foregroundColor(.label)
                    }
                }
                .keyboardShortcut(.init("t"), modifiers: [.command])
                
                Spacer()
                
                if viewModel.canBeClosed {
                    Button {
                        viewModel.close()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.label)
                            .frame(width: DesignSystem.Buttons.iconWidth)
                    }
                }
            }
        }
        .padding(.trailing, .md)
    }
}
