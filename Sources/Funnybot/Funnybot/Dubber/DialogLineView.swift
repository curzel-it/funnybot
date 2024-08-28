//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation
import Schwifty
import SwiftUI

struct DialogLineView: View {
    @EnvironmentObject var dubber: DubberViewModel
    @StateObject var viewModel: DialogLineViewModel
    
    init(line: DialogLine) {
        let vm = DialogLineViewModel(line: line)
        _viewModel = StateObject(wrappedValue: vm)
    }
        
    var body: some View {
        HStack(spacing: .md) {
            Text("\(viewModel.speaker)")
                .textAlign(.leading)
                .frame(width: 100)
            
            Text(viewModel.text)
                .textAlign(.leading)
                .font(.title3)
                .textSelection(.enabled)
            
            Spacer()
            
            if viewModel.canPlay {
                PlayButton(fileURL: viewModel.line.url)
            }
            RecordingButton(for: viewModel.line)
            
            Button {
                viewModel.pickFile()
            } label: {
                Image(systemName: "folder")
            }
            
            Button {
                viewModel.dub()
            } label: {
                Image(systemName: "waveform.path")
            }
        }
        .padding(.vertical, .sm)
        .onAppear { viewModel.dubber = dubber }
    }
}
