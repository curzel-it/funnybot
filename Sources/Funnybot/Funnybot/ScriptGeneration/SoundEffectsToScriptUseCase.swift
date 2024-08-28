//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation
import Funnyscript

protocol SoundEffectsToScriptUseCase {
    func suggestions(for episode: Episode) async throws -> String
}

enum SoundEffect: String, CaseIterable {
    case airhorn = "airhorn"
    case animeWow = "anime_wow"
    case applauseSort = "applause_sort"
    case araAra = "ara_ara"
    case beethovenTheDestinySymphony = "beethoven_the_destiny_symphony"
    case bruh = "bruh"
    case fbiOpenTheDoor = "fbi_open_the_door"
    case illuminatiConfirmed = "illuminati_confirmed"
    case nani = "nani"
    case marioJump = "mario_jump"
    case metalGearSolidAlert = "metal_gear_solid_alert"
    case ohMyGah = "oh_my_gah"
    case vineBoomSound = "vine_boom_sound"
    case windowsXpStartup = "windows_xp_startup"
}

class SoundEffectsToScriptUseCaseImpl: SoundEffectsToScriptUseCase {
    @Inject private var model: GenerativeAiWorkingModel
    @Inject private var prompts: PromptBuilderUseCase
    @Inject private var indexedDialogs: IndexedDialogsUseCase
    
    func suggestions(for episode: Episode) async throws -> String {
        let dialogs = try await indexedDialogs.indexedDialogs(for: episode)
        let transcript = dialogs.transcript()
        
        let response = try await model.ask(prompt: systemPrompt(for: episode), question: transcript)
                
        return response
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isBlank }
            .compactMap {
                do {
                    let tokens = $0.components(separatedBy: ":")
                    let index = try Int(try tokens.first.unwrap()).unwrap()
                    let effect = try tokens.last.unwrap().trimmingCharacters(in: .whitespacesAndNewlines)
                    let command = "overlay_blocking: play \(effect) 1"
                    let item = try dialogs.first { $0.index == index }.unwrap()
                    return "\(item.subject): \"\(item.dialog)\"\n\(command)"
                } catch {
                    return nil
                }
            }
            .joined(separator: "\n\n")
    }
    
    func systemPrompt(for episode: Episode) -> String {
        prompts.build(
            templateName: "system_prompt_suggest_sound_effects",
            for: episode,
            userInput: availableItems(),
            notes: ""
        )
    }
    
    func availableItems() -> String {
        SoundEffect.allCases
            .map { "* \($0.rawValue)" }
            .joined(separator: "\n")
    }
}
