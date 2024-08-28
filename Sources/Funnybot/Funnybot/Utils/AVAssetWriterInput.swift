import AVFoundation

extension AVAssetWriterInput {
    func waitUntilReadyForMoreMediaData(waitTime: ContinuousClock.Instant.Duration = .milliseconds(50)) async throws {
        while !isReadyForMoreMediaData {
            try await Task.sleep(for: waitTime)
        }
    }
}
