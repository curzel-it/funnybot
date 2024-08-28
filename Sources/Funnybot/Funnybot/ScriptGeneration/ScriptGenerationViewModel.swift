//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation
import AskGpt
import SwiftUI
import Combine
import SwiftData
import Funnyscript

class ScriptGenerationViewModel: ObservableObject {
    @Inject private var appViewModel: AppViewModel
    @Inject private var container: ModelContainer
    @Inject private var dialogs: ScriptGenerationUseCase
    @Inject private var soundEffects: SoundEffectsToScriptUseCase
    @Inject private var callToActions: CallToActionsToScriptUseCase
    @Inject private var parser: Funnyscript.Parser
    
    @Published var transcript: String = ""
    @Published var prompt: String = ""
    @Published var characters: [SeriesCharacter] = []
    @Published var isLoading = false
    @Published var autoGenerationEnabled: Bool = false
    
    var title: String {
        "\(episode.title) - Group Chat"
    }
    
    private let episode: Episode
    private var disposables = Set<AnyCancellable>()
    
    init(episode: Episode) {
        self.episode = episode
        self.characters = (episode.series?.characters ?? []).sorted()
        
        Task { @MainActor in
            loadTranscript()
            bindAutoSave()
        }
    }
    
    func goWild() {
        Task {
            await goWildNow()
        }
    }
    
    func copyScript() {
#if os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(transcript, forType: .string)
#else
        let pasteboard = UIPasteboard.general
        pasteboard.string = transcript
        #endif
    }
    
    func format() {
        Task {
            do {
                let formatted = try await parser
                    .instructions(from: transcript)
                    .map { $0.description }
                    .joined(separator: "\n")
                await setTranscript(formatted)
            } catch {
                appViewModel.message(text: "Failed to format: \(error)")
            }
        }
    }
    
    func goWildNow() async {
        await setAutoGenerating(true)
        await setLoading(true)
        
        while autoGenerationEnabled {
            do {
                let response = try await dialogs.continueDialog(for: episode, notes: prompt)
                await setPrompt("")
                await appendTranscript(response)
            } catch {
                appViewModel.message(text: "Something went wrong: \(error)")
                break
            }
        }
        
        await setAutoGenerating(false)
        await setLoading(false)
    }
    
    func stopGenerating() {
        Task { @MainActor in
            setAutoGenerating(false)
        }
    }
    
    func addSoundEffects() {
        Task {
            do {
                let suggestions = try await soundEffects.suggestions(for: episode)
                appViewModel.message(text: suggestions)
            } catch {
                appViewModel.message(text: "Error: \(error)")
            }
        }
    }
    
    func addCallToActions() {
        Task {
            do {
                let suggestions = try await callToActions.suggestions(for: episode)
                appViewModel.message(text: suggestions)
            } catch {
                appViewModel.message(text: "Error: \(error)")
            }
        }
    }
    
    @MainActor
    private func setAutoGenerating(_ enabled: Bool) {
        autoGenerationEnabled = enabled
    }
    
    @MainActor
    private func setPrompt(_ text: String) {
        prompt = text
    }
    
    @MainActor
    private func appendTranscript(_ text: String) {
        let addition = "\n\n\(text)"
        let updated = (transcript + addition).trimmingCharacters(in: .whitespacesAndNewlines)
        setTranscript(updated)
    }
    
    @MainActor
    private func setTranscript(_ text: String) {
        transcript = text
        episode.script = text
        try? container.mainContext.save()
    }
    
    @MainActor
    private func setLoading(_ isLoading: Bool) {
        self.isLoading = isLoading
    }
    
    @MainActor
    private func loadTranscript() {
        transcript = episode.script
    }
    
    private func bindAutoSave() {
        $transcript
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { value in
                Task { @MainActor [weak self] in
                    self?.save(text: value)
                }
            }
            .store(in: &disposables)
    }
    
    @MainActor
    private func save(text: String) {
        episode.script = text
        try? container.mainContext.save()
    }
}
