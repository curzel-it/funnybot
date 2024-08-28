//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import AVFoundation
import Foundation
import Schwifty
import SwiftUI

enum RecordingButtonState {
    case idle
    case failed
    case recording
    case saving
    
    var icon: String {
        switch self {
        case .idle: "record.circle.fill"
        case .failed: "exclamationmark.triangle.fill"
        case .recording: "stop.fill"
        case .saving: "hourglass"
        }
    }
}

struct RecordingButton: View {
    private let audioRecorder: AudioRecorder
    private let line: DialogLine
    
    @State var state: RecordingButtonState = .idle
    
    @Inject private var dubs: DubsStorage
    
    init(for line: DialogLine) {
        self.line = line
        audioRecorder = AudioRecorder(audioFilename: line.url)
    }
    
    var body: some View {
        Button {
            switch state {
            case .idle: startRecording()
            case .failed: startRecording()
            case .recording: stopRecording()
            case .saving: break
            }
        } label: {
            Image(systemName: state.icon)
        }
    }
    
    private func stopRecording() {
        audioRecorder.stopRecording()
        withAnimation {
            state = .saving
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            processRecording(at: audioRecorder.targetDestination)
        }
    }
    
    private func processRecording(at url: URL) {
        do {
            let data = try Data(contentsOf: url)
            try dubs.save(speaker: line.speaker, line: line.line, data: data)
            withAnimation {
                state = .idle
            }
        } catch {
            withAnimation {
                state = .failed
            }
        }
    }
    
    private func startRecording() {
        try? audioRecorder.startRecording()
        withAnimation {
            state = .recording
        }
    }
}
