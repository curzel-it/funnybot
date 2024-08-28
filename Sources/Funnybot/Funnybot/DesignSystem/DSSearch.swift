//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation
import Schwifty
import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: .sm) {
            Image(systemName: "magnifyingglass")
            TextField("", text: $text)
                .textFieldStyle(.plain)
        }
        .padding(.horizontal, .md)
        .frame(height: 32)
        .dimBackground()
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
