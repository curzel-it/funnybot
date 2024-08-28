//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation
import SwiftUI
import SwiftData
import Schwifty

struct CharactersView: View {
    let series: Series
    
    @EnvironmentObject var viewModel: TabViewModel
    @State var searchTerms: String = ""
    @State var characters: [SeriesCharacter] = []
    
    var title: String {
        let totalCount = series.characters?.count ?? 0
        let filteredCount = characters.count
        let countLabel = totalCount == filteredCount ? "\(totalCount)" : "\(filteredCount) out of \(totalCount)"
        return "Characters of \(series.title) (\(countLabel))"
    }
    
    init(series: Series) {
        self.series = series        
        reloadCharacters(searchTerms: "")
    }
    
    var body: some View {
        VStack(spacing: .md) {
            HStack(spacing: .md) {
                Text(title).pageTitleFont()
                
                SearchBar(text: $searchTerms)
                    .frame(width: 140)
                
                Button("New Character") {
                    newCharacter()
                }
                Spacer()
            }
            .padding(.horizontal, .md)
            
            DSList(characters) {
                CharacterListItem(character: $0)
            }
        }
        .onAppear {
            reloadCharacters(searchTerms: searchTerms)
        }
        .onChange(of: searchTerms) { _, newTerms in
            reloadCharacters(searchTerms: newTerms)
        }
    }
    
    private func reloadCharacters(searchTerms: String) {
        let terms = searchTerms.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        characters = series.characters?
            .filter { terms == "" || $0.name.lowercased().contains(terms) || $0.path.lowercased().contains(terms) }
            .sorted() ?? []
    }
    
    private func newCharacter() {
        let character = SeriesCharacter(series: series, name: "New Character", path: "", about: "")
        viewModel.navigate(to: character)
    }
}
