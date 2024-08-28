//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation

struct SubtitleItem {
    let index: Int
    let text: String
    let startTime: TimeInterval
    let duration: TimeInterval
    
    var endTime: TimeInterval {
        startTime + duration
    }
    func byJoining(_ otherSub: SubtitleItem) -> SubtitleItem {
        SubtitleItem(
            index: index,
            text: "\(text) \(otherSub.text)",
            startTime: startTime,
            duration: otherSub.endTime - startTime
        )
    }
    
    func with(index: Int) -> SubtitleItem {
        SubtitleItem(index: index, text: text, startTime: startTime, duration: duration)
    }
}
