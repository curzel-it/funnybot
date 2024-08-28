//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import SwiftUI

struct DSTextView: View {
    @Binding var value: String
    
    var body: some View {
        TextEditor(text: $value)
            .monospaced()
            .textEditorStyle(.plain)
            .padding(.vertical, .sm)
            .textFieldBackground()
            .scrollDisabled(false)
    }
}
