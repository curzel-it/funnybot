//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import AVFoundation
import Foundation
import Schwifty
import SwiftUI

struct PlayButton: View {
    @StateObject private var viewModel: PlayButtonViewModel
    
    private let tag = "PlayButton"
    
    init(fileURL: URL) {
        _viewModel = StateObject(wrappedValue: PlayButtonViewModel(fileURL: fileURL))
    }
    
    var body: some View {
        Button {
            viewModel.togglePlayback()
        } label: {
            if viewModel.isPlaying {
                Image(systemName: "stop.fill")
            } else {
                Image(systemName: "play.fill")
            }
        }
    }
}

private class PlayButtonViewModel: NSObject, ObservableObject {
    @Published var isPlaying: Bool = false
    
    private var audioPlayer: AVAudioPlayer?
    private let fileURL: URL
    private let tag = "PlayButtonViewModel"
    
    init(fileURL: URL) {
        self.fileURL = fileURL
        super.init()
    }
    
    func togglePlayback() {
        if isPlaying {
            stopPlaying()
        } else {
            startPlaying()
        }
    }
    
    private func stopPlaying() {
        audioPlayer?.stop()
        isPlaying = false
    }
    
    private func startPlaying() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            audioPlayer?.delegate = self
            isPlaying = true
        } catch {
            Logger.debug(tag, "Audio player could not be initialized.")
        }
    }
}

extension PlayButtonViewModel: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
    }
}
