//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation
import Schwifty

public enum ParserError: Error {
    case multipleColons(line: Int, text: String)
    case noAction(line: Int, text: String)
    case invalidMacroDefinition(line: Int, text: String)
    case undefinedMacro(line: Int, text: String)
    
    public var text: String {
        switch self {
        case .multipleColons(_, let text): text
        case .noAction(_, let text): text
        case .invalidMacroDefinition(_, let text): text
        case .undefinedMacro(_, let text): text
        }
    }
}

public class Parser {
    private let config: Config
    private let charactersProvider: CharactersProvider
    
    lazy var addons: [any ParserAddon] = {
        [
            CameraActionsParser(usingAutoCamera: !config.useManualCamera),
            DialogsParser(config: config, charactersProvider: charactersProvider)
        ]
    }()

    private let positionParser = ScenePositionParser()
    private let tag = "Parser"
    
    private var instructions: [Instruction] = []
    private var isParsingMultilineComment = false
    private var isParsingMultilineDialog = false
    private var isParsingMacro = false
    private var macros: [String: [Instruction]] = [:]
    private var currentSubject = ""
    private var currentMacroInstructions: [Instruction] = []
    private var currentMacroName = ""
    
    var lineText: String = ""
    var lineIndex: Int = 0
    
    public init(config: Config, charactersProvider: CharactersProvider) {
        self.config = config
        self.charactersProvider = charactersProvider
    }
    
    public func instructions(from script: String) async throws -> [Instruction] {
        Logger.debug(tag, "Parsing \(script.count) characters...")
        reset()
        
        let lines = script
            .components(separatedBy: "\n")
            .enumerated()
            .map { (index, line) in (index, stripInlineCommentsAndTrim(from: line)) }
            .map { (index, line) in (index, stripCutaways(from: line)) }
            .filter { (index, line) in !line.isEmpty }
        
        Logger.debug(tag, "Found \(lines.count) lines...")
        
        for (index, line) in lines {
            lineText = line
            lineIndex = index
            
            if parseMultilineCommentStart() { continue }
            if parseMultilineCommentEnd() { continue }
            if try parseMacroStart() { continue }
            if parseMacroEnd() { continue }
            if parseMultilineDialogStart() { continue }
            if parseMultilineDialogEnd() { continue }
            
            guard !isParsingMultilineComment else { continue }
                        
            let newInstructions: [Instruction]
            if let invocation = parseMacroInvocation() {
                newInstructions = try instructions(forMacroInvocation: invocation)
            } else {
                newInstructions = try await parseInstructions()
            }
            for instruction in newInstructions {
                Logger.debug(tag, "Parsed `\(instruction)`")
            }
            assign(newInstructions)
        }
        Logger.debug(tag, "Done!")
        return instructions
    }
    
    func reset() {
        instructions = []
        isParsingMultilineComment = false
        isParsingMultilineDialog = false
        isParsingMacro = false
        macros = [:]
        currentSubject = ""
        currentMacroInstructions = []
        currentMacroName = ""
    }
    
    private func parseMultilineDialogStart() -> Bool {
        guard lineText.hasSuffix(":") else { return false }
        let tokens = lineText
            .components(separatedBy: ":")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        guard tokens.count == 2 else { return false }
        guard tokens[1].isEmpty else { return false }
        isParsingMultilineDialog = true
        currentSubject = tokens[0].lowercased()
        return true
    }
    
    private func parseMultilineDialogEnd() -> Bool {
        guard isParsingMultilineDialog else { return false }
        guard lineText.components(separatedBy: ":").count != 2  else { return false }
        
        let instruction = Instruction(
            subject: currentSubject,
            action: .talking(line: lineText, info: "")
        )
        instructions.append(instruction)
        return true
    }
    
    private func parseMacroInvocation() -> MacroInvocation? {
        macros[lineText] != nil ? lineText : nil
    }
    
    private func instructions(forMacroInvocation invocation: MacroInvocation) throws -> [Instruction] {
        do {
            return try macros[invocation].unwrap()
        } catch {
            throw ParserError.undefinedMacro(line: lineIndex, text: lineText)
        }
    }
    
    func assign(_ newInstructions: [Instruction]) {
        if isParsingMacro {
            currentMacroInstructions.append(contentsOf: newInstructions)
        } else {
            instructions.append(contentsOf: newInstructions)
        }
    }
    
    func parseMacroStart() throws -> Bool {
        if lineText.hasPrefix("def") {
            do {
                currentMacroName = try lineText
                    .substring(delimitedBy: "def ", and: ":")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .throwIfBlank()
            } catch {
                throw ParserError.invalidMacroDefinition(line: lineIndex, text: lineText)
            }
            isParsingMacro = true
            return true
        }
        return false
    }
    
    func parseMacroEnd() -> Bool {
        if lineText == "end" {
            isParsingMacro = false
            macros[currentMacroName] = currentMacroInstructions
            currentMacroInstructions = []
            currentMacroName = ""
            return true
        }
        return false
    }
    
    func parseMultilineCommentStart() -> Bool {
        if lineText.hasPrefix("/*") {
            isParsingMultilineComment = true
            return true
        }
        return false
    }
    
    func parseMultilineCommentEnd() -> Bool {
        if lineText.hasPrefix("*/") {
            isParsingMultilineComment = false
            return true
        }
        return false
    }
    
    func stripCutaways(from line: String) -> String {
        if line.hasPrefix("[") && line.hasSuffix("]") { return "" }
        if line.hasPrefix("<") && line.hasSuffix(">") { return "" }
        return line
    }
    
    func stripInlineCommentsAndTrim(from line: String) -> String {
        line
            .components(separatedBy: "#")
            .first?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "“", with: "\"")
            .replacingOccurrences(of: "”", with: "\"")
            .replacingOccurrences(of: "＂", with: "\"") ?? ""
    }
    
    func parseInstructions() async throws -> [Instruction] {
        let (subject, actionText) = try subjectAndActionText()
        
        if let action = await action(from: actionText, subject: subject) {
            return [Instruction(subject: subject, action: action)]
        }
        for addon in addons {
            if let instructions = try await addon.instructions(from: actionText, subject: subject) {
                return instructions
            }
        }
        throw ParserError.noAction(line: lineIndex, text: actionText)
    }
    
    func subjectAndActionText() throws -> (String, String) {
        let tokens = tokenize(lineText)
        
        guard tokens.count == 2 else {
            throw ParserError.multipleColons(line: lineIndex, text: lineText)
        }
        let subject = tokens[0].lowercased()
        let action = tokens[1]
        return (subject, action)
    }
    
    func tokenize(_ text: String) -> [String] {
        let line = text.trimmingCharacters(in: .whitespaces)
        
        var result = [String]()
        var currentSegment = ""
        var insideQuotes = false

        for char in line {
            if char == "\"" {
                insideQuotes.toggle()
            }

            if char == ":", !insideQuotes {
                result.append(currentSegment)
                currentSegment = ""
            } else {
                currentSegment.append(char)
            }
        }

        if !currentSegment.isEmpty {
            result.append(currentSegment)
        }
        return result.map { $0.trimmingCharacters(in: .whitespaces) }
    }
    
    func action(from originalText: String, subject: String) async -> Action? {
        let text = originalText.lowercased()
        switch subject {
        case "scene":
            if let action = clearStageAction(from: text) { return action }
            if let action = changeBackgroundAction(from: text) { return action }
            if let action = pauseAction(from: text) { return action }
            if let action = shuffleAction(from: text) { return action }
        default:
            if let action = coordinateSetAction(from: text) { return action }
            if let action = offsetAction(from: text) { return action }
            if let action = animationAction(from: text) { return action }
            if let action = movementAction(from: text) { return action }
            if let action = opacityAction(from: text) { return action }
            if let action = placementAction(from: text) { return action }
            if let action = turningAction(from: text) { return action }
            if let action = scaleAction(from: text) { return action }
        }
        return nil
    }
    
    private func scaleAction(from actionText: String) -> Action? {
        guard actionText.hasPrefix("scale") else { return nil }
        guard let value = Double(actionText.lastWord() ?? "") else { return nil }
        return .scale(value: CGFloat(value))
    }
    
    private func coordinateSetAction(from actionText: String) -> Action? {
        let words = actionText.components(separatedBy: " ")
        guard words.count == 3, words[0] == "set" else { return nil }
        guard let value = Double(words[2]) else { return nil }
        guard let axis = Axis(rawValue: words[1]) else { return nil }
        return .coordinateSet(axis: axis, value: CGFloat(value))
    }
    
    private func offsetAction(from actionText: String) -> Action? {
        let words = actionText.components(separatedBy: " ")
        guard words.count == 3, words[0] == "offset" else { return nil }
        guard let value = Double(words[2]) else { return nil }
        guard let axis = Axis(rawValue: words[1]) else { return nil }
        return .offset(axis: axis, value: CGFloat(value))
    }
    
    private func clearStageAction(from actionText: String) -> Action? {
        actionText == "clear" ? .clearStage : nil
    }
    
    private func animationAction(from actionText: String) -> Action? {
        let tokens = actionText.components(separatedBy: " ")
        guard tokens.count == 2 || tokens.count == 3 else { return nil }
        guard tokens[0] == "play" else { return nil }
        let loops = tokens.count == 3 ? Int(tokens[2]) : nil
        
        if let emotion = Emotion(rawValue: tokens[1].lowercased()) {
            return .emotion(emotion: emotion)
        }
        return .animation(id: tokens[1], loops: loops)
    }
    
    private func changeBackgroundAction(from actionText: String) -> Action? {
        guard actionText.hasPrefix("background") else { return nil }
        let name = actionText
            .replacingOccurrences(of: "background ", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return .background(name: name)
    }
    
    private func opacityAction(from actionText: String) -> Action? {
        let validStarters = ["fade to", "fade in", "fade out", "opacity"]
        let hasValidPrefix = validStarters.contains { actionText.hasPrefix($0) }
        let smoothly = actionText.contains("fade")
        
        let value: Double? = switch actionText.lastWord() ?? "" {
        case "out": 0
        case "in": 1
        default: Double(actionText.lastWord() ?? "")
        }
        
        guard hasValidPrefix, let value else { return nil }
        return .opacity(value: value, smoothly: smoothly)
    }
    
    private func pauseAction(from actionText: String) -> Action? {
        guard actionText.hasPrefix("pause"),
              let durationText = actionText.components(separatedBy: " ").last,
              let duration = Double(durationText)
        else { return nil }
        return .pause(duration: duration)
    }
    
    private func shuffleAction(from actionText: String) -> Action? {
        guard actionText.hasPrefix("shuffle") else { return nil }
        let hard = actionText.contains("hard")
        let value = Int(actionText.components(separatedBy: " ").last ?? "")
        return .shuffle(hard: hard, count: value)
    }
    
    private func movementAction(from text: String) -> Action? {
        guard let placeName = text.lastWord() else { return nil }
        guard let speedName = text.firstWord() else { return nil }
        guard let speed = MovementSpeed(rawValue: speedName) else { return nil }
        
        if let position = scenePosition(from: placeName) {
            return .movement(destination: .scenePosition(position: position), speed: speed)
        }
        return .movement(destination: .entity(id: placeName), speed: speed)
    }
    
    private func turningAction(from text: String) -> Action? {
        guard text.hasPrefix("turn") else { return nil }
        guard let placeName = text.lastWord() else { return nil }
        
        switch placeName {
        case "right": return .turn(target: .right)
        case "left": return .turn(target: .left)
        case "front": return .turn(target: .front)
        default: return .turn(target: .entity(id: placeName))
        }
    }
    
    private func placementAction(from text: String) -> Action? {
        guard text.hasPrefix("at ") else { return nil }
        guard let placeName = text.lastWord() else { return nil }
        
        if let position = scenePosition(from: placeName) {
            return .placement(destination: .scenePosition(position: position))
        }
        return .placement(destination: .entity(id: placeName))
    }
    
    private func scenePosition(from text: String?) -> ScenePosition? {
        if let text {
            positionParser.scenePosition(from: text)
        } else {
            nil
        }
    }
}

extension String {
    func firstWord() -> String? {
        components(separatedBy: " ").first?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func lastWord() -> String? {
        components(separatedBy: " ").last?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    @discardableResult
    func throwIfBlank() throws -> String {
        if isBlank {
            throw StringError.unexpectedBlankString
        }
        return self
    }
}

private enum StringError: Error {
    case unexpectedBlankString
}

private typealias MacroInvocation = String
