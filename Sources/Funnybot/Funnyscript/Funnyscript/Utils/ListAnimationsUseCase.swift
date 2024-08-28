//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation
import Schwifty

public class ListAnimationsUseCase {
    private let assets: AssetsProvider
    
    public init(assets: AssetsProvider) {
        self.assets = assets
    }
    
    public func listAnimations(in instructions: [Instruction]) -> [String] {
        instructions
            .compactMap {
                if case .animation(let id, _) = $0.action {
                    "\($0.subject)_\(id)-1"
                } else {
                    nil
                }
            }
            .sorted()
            .removeDuplicates(keepOrder: true)
    }
    
    public func listMissingAnimations(in instructions: [Instruction]) -> [String] {
        listAnimations(in: instructions)
            .filter { assets.image(sprite: $0) == nil }
    }
}
