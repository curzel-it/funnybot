//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation

public class Config {
    public static let shared: Config = Config()
    
    public var pixelPerfectMovement: Bool = false
    public var frameTime: TimeInterval = 0.1
    public var fps: TimeInterval = 10
}
