//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import XCTest

@testable import Funnyscript

final class ScenePositionParserTests: XCTestCase {
    private var parser: ScenePositionParser!
    private let mock = MockDependencies()
    
    override func setUp() async throws {
        parser = ScenePositionParser()
        try await super.setUp()
    }
    
    func testKnownPositions() throws {
        XCTAssertEqual(parser.scenePosition(from: "center"), .center)
        XCTAssertEqual(parser.scenePosition(from: "centerRight"), .centerRight)
        XCTAssertEqual(parser.scenePosition(from: "centerLeft"), .centerLeft)
        XCTAssertEqual(parser.scenePosition(from: "midRight"), .midRight)
        XCTAssertEqual(parser.scenePosition(from: "midLeft"), .midLeft)
        XCTAssertEqual(parser.scenePosition(from: "farRight"), .farRight)
        XCTAssertEqual(parser.scenePosition(from: "farLeft"), .farLeft)
        XCTAssertEqual(parser.scenePosition(from: "outsideRight"), .outsideRight)
        XCTAssertEqual(parser.scenePosition(from: "outsideLeft"), .outsideLeft)
        XCTAssertEqual(parser.scenePosition(from: "outsideRightBelow"), .outsideRightBelow)
    }
}
