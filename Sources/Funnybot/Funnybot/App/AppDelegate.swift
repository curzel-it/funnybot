//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import SwiftUI
import Schwifty

class AppDelegate: NSObject, NSApplicationDelegate {
    @Inject private var broker: RuntimeEventsBroker

    func applicationDidFinishLaunching(_ notification: Notification) {
        broker.send(.appLaunched)
    }

    func applicationWillTerminate(_ notification: Notification) {
        broker.send(.appWillTerminate)
    }
}
