//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation

protocol PromptBuilderUseCase {
    func build(template: String, for episode: Episode, userInput: String, notes: String) -> String
    func build(templateName: String, for episode: Episode, userInput: String, notes: String) -> String
}

extension PromptBuilderUseCase {
    func build(template: String, for episode: Episode, userInput: String = "", notes: String = "") -> String {
        build(template: template, for: episode, userInput: userInput, notes: notes)
    }
    
    func build(templateName: String, for episode: Episode, userInput: String = "", notes: String = "") -> String {
        build(templateName: templateName, for: episode, userInput: userInput, notes: notes)
    }
}

class PromptBuilderUseCaseImpl: PromptBuilderUseCase {
    @Inject private var config: ConfigStorageService
    
    func build(template: String, for episode: Episode, userInput: String, notes: String) -> String {
        PromptKey.allCases
            .reduce(template) { partialResult, key in
                let value = value(key: key, episode: episode, userInput: userInput, notes: notes)
                return partialResult.replacingOccurrences(of: "{{\(key)}}", with: value)
            }
    }
    
    func build(templateName: String, for episode: Episode, userInput: String, notes: String) -> String {
        build(template: docFile(named: templateName), for: episode, userInput: userInput, notes: notes)
    }
    
    private func value(key: PromptKey, episode: Episode, userInput: String, notes: String) -> String {
        switch key {
        case .episodeConcept: episode.concept
        case .episodeScript: episode.script
        case .episodeTitle: episode.title
        case .funnyscriptDocs: funnyscriptDocs()
        case .language: config.current.language
        case .notes: notes
        case .seriesCharacters: seriesCharacters(from: episode)
        case .seriesMainCharacters: seriesCharacters(from: episode) { $0.isMainCast }
        case .seriesContext: seriesContext(from: episode)
        case .userInput: userInput
        }
    }
    
    private func funnyscriptDocs() -> String {
        let docs = docFile(named: "script_format")
        let interpreterOptions = try? docs.substring(
            delimitedBy: "<!-- interpreter options start -->",
            and: "<!-- interpreter options end -->"
        )
        let facingDirection = try? docs.substring(
            delimitedBy: "<!-- facing direction start -->",
            and: "<!-- facing direction end -->"
        )
        let cameraDirectives = try? docs.substring(
            delimitedBy: "<!-- camera directives start -->",
            and: "<!-- camera directives end -->"
        )
        return docs
            .replacingOccurrences(of: interpreterOptions ?? "", with: "")
            .replacingOccurrences(of: facingDirection ?? "", with: "")
            .replacingOccurrences(of: cameraDirectives ?? "", with: "")
    }
    
    private func seriesCharacters(from episode: Episode) -> String {
        seriesCharacters(from: episode) { !$0.about.isEmpty }
    }
    
    private func seriesCharacters(from episode: Episode, filter: @escaping (SeriesCharacter) -> Bool) -> String {
        episode.series?.characters?
            .sorted()
            .filter(filter)
            .map { "##\($0.name)\n\($0.about)" }
            .joined(separator: "\n\n") ?? ""
    }
    
    private func seriesContext(from episode: Episode) -> String {
        let value = episode.series?.about ?? ""
        let fallback = "The show is an animated show targeted at adults"
        return value.isBlank ? fallback : value
    }
    
    private func docFile(named name: String) -> String {
        String(contentsOfResource: name, withExtension: "md", subdirectory: "Docs") ?? ""
    }
}

private enum PromptKey: String, CaseIterable {
    case episodeConcept
    case episodeScript
    case episodeTitle
    case funnyscriptDocs
    case language
    case notes
    case seriesCharacters
    case seriesMainCharacters
    case seriesContext
    case userInput
}
