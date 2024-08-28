//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Combine
import Foundation
import Schwifty

#if os(macOS)
import IOKit.pwr_mgt

class PowerManagementUseCase {
    @Inject private var broker: RuntimeEventsBroker
    
    private var assertionID: IOPMAssertionID = 0
    private var success: IOReturn?
    private var disposables = Set<AnyCancellable>()
    private let tag = "PowerManagementUseCase"

    init() {
        DispatchQueue.main.async { [weak self] in
            self?.bindAppLaunch()
            self?.bindAppTermination()
        }
    }
    
    func bindAppLaunch() {
        broker.events()
            .filter { $0 == .appLaunched }
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.preventSleep(reason: "Do i really need to explain?")
            }
            .store(in: &disposables)
    }
    
    func bindAppTermination() {
        broker.events()
            .filter { $0 == .appWillTerminate }
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.allowSleep()
            }
            .store(in: &disposables)
    }
    
    func preventSleep(reason: String) {
        success = IOPMAssertionCreateWithName(
            kIOPMAssertionTypeNoIdleSleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason as CFString,
            &assertionID
        )

        if success == kIOReturnSuccess {
            Logger.debug(tag, "Power management assertion created successfully. System will not sleep.")
        } else {
            Logger.debug(tag, "Failed to create power management assertion.")
        }
    }

    func allowSleep() {
        if success == kIOReturnSuccess {
            IOPMAssertionRelease(assertionID)
            Logger.debug(tag, "Power management assertion released. System can sleep now.")
        }
    }
}
#else
class PowerManagementUseCase {
    private let tag = "PowerManagementUseCase"
    
    init() {
        Logger.debug(tag, "This does nothing on iOS")
    }
}
#endif
