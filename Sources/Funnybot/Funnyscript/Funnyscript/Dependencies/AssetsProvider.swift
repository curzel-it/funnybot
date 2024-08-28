//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import NotAGif
import Foundation

public protocol AssetsProvider {
    func image(sprite: String?) -> ImageFrame?
    func numberOfFrames(for species: String, animation: String) -> Int
}
