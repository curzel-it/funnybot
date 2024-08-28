//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation

protocol SRTFormattingUseCase {
    func srt(for subs: [SubtitleItem]) -> String
}

class SRTFormattingUseCaseImpl: SRTFormattingUseCase {
    func srt(for subs: [SubtitleItem]) -> String {
        subs.map { srt(for: $0) }.joined(separator: "\n\n")
    }
    
    func srt(for sub: SubtitleItem) -> String {
        let startTimeString = srtDate(for: sub.startTime)
        let endTimeString = srtDate(for: sub.endTime)
        return "\(sub.index)\n\(startTimeString) --> \(endTimeString)\n\(sub.text)"
    }
    
    func srtDate(for time: TimeInterval) -> String {
        let hh = Int(time / 3600)
        let mm = Int((time / 60).truncatingRemainder(dividingBy: 60))
        let ss = Int(time.truncatingRemainder(dividingBy: 60))
        let ms = Int((time - Double(ss) - Double(mm * 60) - Double(hh * 3600)) * 1000)
        return String(format: "%02d:%02d:%02d,%03d", hh, mm, ss, ms)
    }
}
