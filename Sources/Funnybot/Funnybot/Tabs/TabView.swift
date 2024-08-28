//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import SwiftUI
import SwiftData

struct TabView: View {
    @StateObject var viewModel: TabViewModel
    
    var body: some View {
        viewModel.current.view()
            .padding(.top, .md)
            .environmentObject(viewModel)
    }
}
