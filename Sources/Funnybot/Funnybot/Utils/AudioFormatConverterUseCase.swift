import AVFoundation
import Schwifty

class AudioFormatConverterUseCase {
    @Inject private var tempFiles: TemporaryFiles
    
    func convert(_ sourceUrl: URL, toFormat outputFormat: AVFileType) async throws -> Data {
        let temp = tempFiles.next()
        try await convert(sourceUrl, toFormat: outputFormat, saveAs: temp)
        return try Data(contentsOf: temp)
    }
        
    func convert(_ sourceUrl: URL, toFormat outputFormat: AVFileType, saveAs outputUrl: URL) async throws {
        let asset = AVURLAsset(url: sourceUrl)
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
            throw NSError(
                domain: "AVAssetExportSession",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Could not create AVAssetExportSession."]
            )
        }
        exportSession.outputURL = outputUrl
        exportSession.outputFileType = outputFormat
        
        try await withCheckedThrowingContinuation { continuation in
            exportSession.exportAsynchronously {
                switch exportSession.status {
                case .completed:
                    continuation.resume()
                    
                case .failed, .cancelled:
                    let error = exportSession.error ?? NSError(
                        domain: "AVAssetExportSession",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Unknown export error"]
                    )
                    continuation.resume(throwing: error)
                    
                default:
                    let error = NSError(
                        domain: "AVAssetExportSession",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Unknown export status"]
                    )
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
