//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation
import Schwifty
import SwiftUI
import SwiftData

struct Homepage: View {
    @EnvironmentObject var viewModel: TabViewModel
    @Query var series: [Series]
    
    private var seriesTitle: String {
        if series.isEmpty {
            "Create your first series 👉"
        } else {
            "Your Series (\(series.count))"
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: .xl) {
                VStack(spacing: .lg) {
                    HStack(spacing: .md) {
                        Text(seriesTitle).pageTitleFont()
                        
                        Button("New Series") {
                            newSeries()
                        }
                        Spacer()
                    }
                    .padding(.horizontal, .md)
                    
                    if series.isEmpty {
                        Text("<Onboarding goes here>")
                            .positioned(.middle)
                    } else {
                        DSList(series, scrollable: false) {
                            SeriesListItem(series: $0)
                        }
                        .padding(.horizontal, .md)
                    }
                }
                
                SettingsView()
            }
            .fillHeight()
        }
    }
    
    func newSeries() {
        let new = Series(title: "New Series", about: "", style: "")
        viewModel.navigate(to: new)
    }
}
