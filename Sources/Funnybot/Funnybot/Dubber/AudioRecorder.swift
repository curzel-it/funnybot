//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import AVFoundation
import QuartzCore
import Schwifty

class AudioRecorder: NSObject, AVAudioRecorderDelegate {
    @objc enum State: Int {
        case None, Record, Play
    }
    
    let originalDestination: URL
    let targetDestination: URL
    var state: State = .None
    var bitRate = 192000
    var sampleRate = 44100.0
    var channels = 1
    private let tag = "AudioRecorder"
    
    private var recorder: AVAudioRecorder?
    private var player: AVAudioPlayer?
  
    init(audioFilename: URL) {
        originalDestination = audioFilename
        targetDestination = audioFilename.replacingFileExtension(with: "m4a")
        super.init()
    }
    
    private func prepare() throws {
        let settings: [String: AnyObject] = [
            AVFormatIDKey : NSNumber(value: Int32(kAudioFormatMPEG4AAC)),
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue as AnyObject,
            AVEncoderBitRateKey: bitRate as AnyObject,
            AVNumberOfChannelsKey: channels as AnyObject,
            AVSampleRateKey: sampleRate as AnyObject
        ]
        recorder = try AVAudioRecorder(url: targetDestination as URL, settings: settings)
        recorder?.delegate = self
        recorder?.prepareToRecord()
    }

    func startRecording() throws {
        try? FileManager.default.removeItem(at: targetDestination)
        try? FileManager.default.removeItem(at: originalDestination)
        
        Logger.debug(tag, "Saving to \(targetDestination)")
        if recorder == nil {
            try prepare()
        }
        recorder?.record()
        state = .Record
    }

    // MARK: - Playback
    func play() throws {
        player = try AVAudioPlayer(contentsOf: targetDestination as URL)
        player?.volume = 1.0
        player?.play()
        state = .Play
    }

    func stopRecording() {
        switch state {
        case .Play:
            player?.stop()
            player = nil
        case .Record:
            recorder?.stop()
            recorder = nil
        default:
            break
        }
        state = .None
    }

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        Logger.debug(tag, "Did finish recording")
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        Logger.debug(tag, "Error occured \(error?.localizedDescription ?? "n/a"))")
    }
}
