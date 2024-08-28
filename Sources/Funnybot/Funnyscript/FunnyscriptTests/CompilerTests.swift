//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import XCTest

@testable import Funnyscript

final class CompilerTests: XCTestCase {
    private var compiler: Compiler!
    private var parser: Parser!
    private let mock = MockDependencies()
    
    override class func setUp() {
        super.setUp()
    }
    
    override func setUp() async throws {
        compiler = Compiler(config: mock, voices: mock, assets: mock)
        parser = Parser(config: mock)
        try await super.setUp()
    }
    
    func testReportsCorrectActors() async throws {
        do {
            let instructions = try parser.instructions(from: script)
            let compiled = try await compiler.compile(instructions: instructions)
            XCTAssertEqual(compiled.actors.sorted(), ["cat_blue", "crow", "sloth", "trex"])
        } catch {
            print(error)
            print(error)
        }
    }
}

private let script = """
scene: background town_center
sloth: at center
cat_blue: at sloth
# All: hanging out and looking bored
sloth: "God I'm so bored today"
trex: at outsideRight
trex: walk to farRight
trex: "Did you guy hear? There's a new IKEA store nearby, there might be some crazy shit there!"
sloth: "That might actually be a good idea"
crow: at centerRight
crow: "Oh man! I heard they have a Swedish meatball piramid!"
cat_blue: "I could use some new pillows..."
trex: "Well, let's fucking go then!"
crow: walk to outsideRight
cat_blue: walk to outsideRight
sloth: walk to outsideRight
trex: walk to outsideRight
scene: pause for 5
"""
