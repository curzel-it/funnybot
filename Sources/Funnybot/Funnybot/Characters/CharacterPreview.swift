//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation
import SwiftUI
import SwiftData
import Schwifty

struct CharacterPreview: View {
    @EnvironmentObject var viewModel: TabViewModel
    
    let character: SeriesCharacter
    
    var body: some View {
        VStack(spacing: .md) {
            Text(character.name).cardTitle()
            
            Button("Select") {
                viewModel.navigate(to: character)
            }
        }
        .card()
    }
}

struct CharacterListItem: View {
    @EnvironmentObject var viewModel: TabViewModel
    
    let character: SeriesCharacter
    
    var body: some View {
        HStack(spacing: .sm) {
            if character.isMainCast {
                Image(systemName: "star")
            }
            Text(character.name)
                .font(.headline)
        }
        .onTapGesture {
            viewModel.navigate(to: character)
        }
    }
}
