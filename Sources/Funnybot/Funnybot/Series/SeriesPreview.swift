//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation
import Schwifty
import SwiftUI
import SwiftData

struct SeriesPreview: View {
    @EnvironmentObject var viewModel: TabViewModel
    
    let series: Series
    
    var body: some View {
        VStack(spacing: .md) {
            Text(series.title).cardTitle()
            
            Button("Select") {
                viewModel.navigate(to: series)
            }
        }
        .card()
    }
}

struct SeriesListItem: View {
    @EnvironmentObject var viewModel: TabViewModel
    
    let series: Series
    
    var body: some View {
        Text(series.title)
            .font(.headline)
            .onTapGesture {
                viewModel.navigate(to: series)
            }
    }
}
