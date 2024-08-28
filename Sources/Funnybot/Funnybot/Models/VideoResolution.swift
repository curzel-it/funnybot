//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation

enum VideoResolution: String, CustomStringConvertible, CaseIterable {
    case fullHd
    case fullHdVertical
    case hd
    case hdVertical
    case sd
    case potato
    case potatoVertical
    
    var description: String {
        "\(name) | \(heightString) | \(resolutionString)"
    }
    
    var name: String {
        switch self {
        case .fullHd: "Full HD"
        case .fullHdVertical: "Full HD Vertical"
        case .hd: "HS"
        case .hdVertical: "HD Vertical"
        case .sd: "SD"
        case .potato: "Potato"
        case .potatoVertical: "Potato Vertical"
        }
    }
    
    var resolutionString: String {
        switch self {
        case .fullHd: "1920 x 1080"
        case .fullHdVertical: "1080 x 1920"
        case .hd: "1280 x 720"
        case .hdVertical: "720 x 1280"
        case .sd: "640 x 360"
        case .potato: "320 x 180"
        case .potatoVertical: "180 x 320"
        }
    }
    
    var heightString: String {
        switch self {
        case .fullHd: "1080p"
        case .fullHdVertical: "1920p"
        case .hd: "720p"
        case .hdVertical: "1280p"
        case .sd: "360p"
        case .potato: "180p"
        case .potatoVertical: "320p"
        }
    }
    
    var size: CGSize {
        switch self {
        case .fullHd: CGSize(width: 1920, height: 1080)
        case .fullHdVertical: CGSize(width: 1080, height: 1920)
        case .hd: CGSize(width: 1280, height: 720)
        case .hdVertical: CGSize(width: 720, height: 1280)
        case .sd: CGSize(width: 640, height: 360)
        case .potato: CGSize(width: 320, height: 180)
        case .potatoVertical: CGSize(width: 180, height: 320)
        }
    }
    
    static func from(_ size: CGSize) -> Self {
        switch size.height {
        case 1920: .fullHdVertical
        case 1080: .fullHd
        case 1280: .hdVertical
        case 720: .hd
        case 360: .sd
        case 320: .potatoVertical
        case 180: .potato
        default: .fullHd
        }
    }
}
