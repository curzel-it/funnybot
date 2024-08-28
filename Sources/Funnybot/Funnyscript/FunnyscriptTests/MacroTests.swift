//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import XCTest

@testable import Funnyscript

final class MacroTests: XCTestCase {
    private var parser: Parser!
    private let mock = MockDependencies()
    
    override func setUp() async throws {
        parser = Parser(config: mock)
        try await super.setUp()
    }
    
    func testCanParseMacroDefinitionAlongWithRegularWithoutErrors() throws {
        let script = """
def hello_world:
    dan: "hello world!"
end

dan: "What's up?"
"""
        let instructions = try? parser.instructions(from: script)
        XCTAssertNotNil(instructions)
        XCTAssertEqual(instructions?.count, 1)
    }
    
    func testCanInjectMacro() throws {
        let script = """
def hello_world:
    dan: "hello world!"
end

hello_world
"""
        let expected: [Instruction] = [
            .init(subject: "dan", action: .talking(line: "hello world!", info: ""))
        ]
        
        let instructions = try? parser.instructions(from: script)
        XCTAssertEqual(instructions, expected)
    }
    
    func testCanParseMultipleMacros() throws {
        let script = """
def scene_andy_room:
    scene: background background_andy_room
    overlay: play none loop
end

def scene_news_studio:
    scene: background background_news_studio
    overlay: play news_studio loop
end

def andy_catch_phrase:
    andy: play shrug loop
    andy: "This guy!"
end

scene_andy_room
dan: "What are you up to Andy?"
andy_catch_phrase
scene_news_studio
andy_catch_phrase
"""
        let expected: [Instruction] = [
            .init(subject: "scene", action: .background(name: "background_andy_room")),
            .init(subject: "overlay", action: .animation(id: "none", loops: nil)),
            .init(subject: "dan", action: .talking(line: "What are you up to Andy?", info: "")),
            .init(subject: "andy", action: .animation(id: "shrug", loops: nil)),
            .init(subject: "andy", action: .talking(line: "This guy!", info: "")),
            .init(subject: "scene", action: .background(name: "background_news_studio")),
            .init(subject: "overlay", action: .animation(id: "news_studio", loops: nil)),
            .init(subject: "andy", action: .animation(id: "shrug", loops: nil)),
            .init(subject: "andy", action: .talking(line: "This guy!", info: ""))
        ]
        
        let instructions = try? parser.instructions(from: script)
        XCTAssertEqual(instructions, expected)
    }
}
