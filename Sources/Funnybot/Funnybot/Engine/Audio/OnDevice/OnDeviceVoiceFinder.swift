//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation
import SwiftData

class OnDeviceVoiceFinder: VoiceFinder {
    @Inject private var modelContainer: ModelContainer
    
    func listVoices() async -> [Voice] {
        var voices = [Voice]()
        
        let process = Process()
        let pipe = Pipe()
        
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["say", "-v", "?"]
        process.standardOutput = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
                        
            let lines = output.split(separator: "\n")
            for line in lines {
                let parts = line.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
                if parts.count > 1 {
                    let voiceID = String(parts[0])
                    let voiceName = parts[1].split(separator: " ").first.map(String.init) ?? ""
                    let voice = Voice(name: voiceName, id: voiceID)
                    voices.append(voice)
                }
            }
        } catch {
            print("Failed to run process: \(error.localizedDescription)")
        }
        
        return voices
    }
    
    func voice(for name: String, in series: Series) -> String? {
        let character = series.characters?.first { $0.matches(nameOrPath: name) }
        let voice = character?.quickVoice?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return voice.isEmpty ? nil : voice
    }
    
    func volumeLevel(for _: String, in _: Series) -> Float {
        1
    }
}
