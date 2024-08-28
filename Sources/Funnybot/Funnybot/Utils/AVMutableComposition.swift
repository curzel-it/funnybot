import AVFoundation
import Schwifty

extension AVMutableComposition {
    func newMutableVideoTrack() throws -> AVMutableCompositionTrack {
        try addMutableTrack(
            withMediaType: .video,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ).unwrap()
    }
    
    func newMutableAudioTrack() throws -> AVMutableCompositionTrack {
        try addMutableTrack(
            withMediaType: .audio,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ).unwrap()
    }
}
