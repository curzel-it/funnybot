//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import XCTest

@testable import Funnyscript

final class ParserTests: XCTestCase {
    private var parser: Parser!
    private let mock = MockDependencies()
    
    override func setUp() async throws {
        parser = Parser(config: mock)
        try await super.setUp()
    }
    
    func testParsePlacementToScenePosition() throws {
        parser.lineIndex = 0
        parser.lineText = "Andy: at Centerleft"
        let instruction = try parser.parseInstruction()
        XCTAssertEqual(instruction.subject, "andy")
        
        let expected: Action = .placement(
            destination: .scenePosition(position: .centerLeft)
        )
        XCTAssertEqual(expected, instruction.action)
    }
    
    func testParsePlacementNearEntity() throws {
        parser.lineIndex = 0
        parser.lineText = "Andy: at bella"
        let instruction = try parser.parseInstruction()
        XCTAssertEqual(instruction.subject, "andy")
        
        let expected: Action = .placement(
            destination: .entity(id: "bella")
        )
        XCTAssertEqual(expected, instruction.action)
    }
    
    func testParseMovementToScenePosition() throws {
        parser.lineIndex = 0
        parser.lineText = "Andy: walk to Centerleft"
        let instruction = try parser.parseInstruction()
        XCTAssertEqual(instruction.subject, "andy")
        
        let expected: Action = .movement(
            destination: .scenePosition(position: .centerLeft), speed: .walk
        )
        XCTAssertEqual(expected, instruction.action)
    }
    
    func testParseMovementToEntity() throws {
        parser.lineIndex = 0
        parser.lineText = "Andy: walk to bella"
        let instruction = try parser.parseInstruction()
        XCTAssertEqual(instruction.subject, "andy")
        
        let expected: Action = .movement(
            destination: .entity(id: "bella"), speed: .walk
        )
        XCTAssertEqual(expected, instruction.action)
    }
    
    func testParseTalkingActionWithNoInfo() throws {
        parser.lineIndex = 0
        parser.lineText = "Andy: \"Geez Rick!\""
        let instruction = try parser.parseInstruction()
        XCTAssertEqual(instruction.subject, "andy")
        
        let expected: Action = .talking(line: "Geez Rick!", info: "")
        XCTAssertEqual(expected, instruction.action)
    }
    
    func testParseTalkingActionWithInfo() throws {
        parser.lineIndex = 0
        parser.lineText = "Andy: \"Geez Rick!\" he said angrily"
        let instruction = try parser.parseInstruction()
        XCTAssertEqual(instruction.subject, "andy")
        
        let expected: Action = .talking(line: "Geez Rick!", info: "he said angrily")
        XCTAssertEqual(expected, instruction.action)
    }
    
    func testParseAnimation() throws {
        parser.lineIndex = 0
        parser.lineText = "Andy: play idle"
        let instruction = try parser.parseInstruction()
        XCTAssertEqual(instruction.subject, "andy")
        
        let expected: Action = .animation(id: "idle", loops: nil)
        XCTAssertEqual(expected, instruction.action)
    }
    
    func testThrowsWhenParsingUnknownStuff() {
        parser.lineIndex = 0
        parser.lineText = "aaa"
        XCTAssertThrowsError(try parser.parseInstruction())
    }
    
    func testIgnoreCommentsInScript() {
        XCTAssertEqual(try parser.instructions(from: "# asd"), [])
    }
    
    func testParseSceneBackground() {
        XCTAssertEqual(
            try parser.instructions(from: "scene: background green"),
            [.init(subject: "scene", action: .background(name: "green"))]
        )
    }
    
    func testParseScenePause() {
        XCTAssertEqual(
            try parser.instructions(from: "scene: pause 5"),
            [.init(subject: "scene", action: .pause(duration: 5))]
        )
    }
    
    func testParseMultilineDialogs() {
        let script = """
doc:
Hello

nick: turn right

nick:
How are you?
"""
        
        let expected: [String] = [
            "doc: \"Hello\"",
            "nick: turn right",
            "nick: \"How are you?\"",
        ]
        let parsedInstructions = try? parser.instructions(from: script)
        let result = parsedInstructions?.map { $0.description } ?? []
        XCTAssertEqual(result, expected)
    }
    
    func testParseSimpleScript() {
        let script = """
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
        
        let expected: [String] = [
            "scene: background town_center",
            "sloth: at center",
            "cat_blue: at sloth",
            "sloth: \"God I'm so bored today\"",
            "trex: at outsideRight",
            "trex: walk to farRight",
            "trex: \"Did you guy hear? There's a new IKEA store nearby, there might be some crazy shit there!\"",
            "sloth: \"That might actually be a good idea\"",
            "crow: at centerRight",
            "crow: \"Oh man! I heard they have a Swedish meatball piramid!\"",
            "cat_blue: \"I could use some new pillows...\"",
            "trex: \"Well, let's fucking go then!\"",
            "crow: walk to outsideRight",
            "cat_blue: walk to outsideRight",
            "sloth: walk to outsideRight",
            "trex: walk to outsideRight",
            "scene: pause 5",
        ]
        let parsedInstructions = try? parser.instructions(from: script)
        let result = parsedInstructions?.map { $0.description } ?? []
        XCTAssertEqual(result, expected)
    }
}
