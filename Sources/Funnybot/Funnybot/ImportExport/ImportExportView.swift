//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import SwiftUI

struct ImportExportView: View {
    @EnvironmentObject var app: AppViewModel
    
    @StateObject var viewModel = ImportExportViewModel()
    
    var body: some View {
        VStack(spacing: .md) {
            Text("Backup and Restore").sectionTitle()
            HStack(spacing: .sm) {
                Button("Export") {
                    viewModel.runExport()
                }
                Button("Import") {
                    viewModel.runImport()
                }
                Button("Wipe all data") {
                    viewModel.runWipe()
                }
                Spacer()
            }
        }
    }
}
