import SwiftUI
import AVFoundation
import Foundation
import Schwifty

enum FramesToVideoComposerError: Error {
    case attemptingToComposeZeroFrames
}

protocol FramesToVideoComposer {
    func compose(frames: [NSImage]) async throws -> URL
}

class FramesToVideoComposerImpl: FramesToVideoComposer {
    @Inject private var configStorage: ConfigStorageService
    @Inject private var renderingMode: SceneRenderingModeUseCase
    @Inject private var tempFiles: TemporaryFiles
    
    private var videoResolution: CGSize = .zero
    private var fps: TimeInterval = .zero
    private var interpolation: NSImageInterpolation = .none
    
    func compose(frames: [NSImage]) async throws -> URL {
        updateConfig()
        
        guard !frames.isEmpty else {
            throw FramesToVideoComposerError.attemptingToComposeZeroFrames
        }
        
        let outputUrl = tempFiles.next(withExtension: "mp4")
        let frameDuration = CMTime(value: 1, timescale: Int32(fps))
        let videoWidth = videoResolution.width
        let videoHeight = videoResolution.height
        
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: videoWidth,
            AVVideoHeightKey: videoHeight,
        ]
        
        let assetWriter = try AVAssetWriter(outputURL: outputUrl, fileType: AVFileType.mp4)
        let assetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        assetWriterInput.expectsMediaDataInRealTime = false
        
        let attributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferWidthKey as String: videoWidth,
            kCVPixelBufferHeightKey as String: videoHeight,
        ]
        let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: assetWriterInput,
            sourcePixelBufferAttributes: attributes
        )
        
        assetWriter.add(assetWriterInput)
        assetWriter.startWriting()
        assetWriter.startSession(atSourceTime: CMTime.zero)
        
        for (index, sourceImage) in frames.enumerated() {
            let frame = sourceImage.resized(to: videoResolution, interpolation: interpolation)
            let presentationTime = CMTimeMultiply(frameDuration, multiplier: Int32(index))
            try await assetWriterInput.waitUntilReadyForMoreMediaData()
            let pixelBuffer = try createPixelBufferFromImage(image: frame)
            pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)
        }
        
        assetWriterInput.markAsFinished()
        await assetWriter.finishWriting()
        if let error = assetWriter.error { throw error }
        
        return outputUrl
    }
    
    private func updateConfig() {
        let config = configStorage.current
        fps = config.fps
        interpolation = renderingMode.imageInterpolation(for: config.renderingMode)
        videoResolution = config.videoResolution
    }
    
    private func createPixelBufferFromImage(image: NSImage) throws -> CVPixelBuffer {
        let width = Int(image.size.width)
        let height = Int(image.size.height)
        var pixelBuffer: CVPixelBuffer?
        
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32BGRA,
            nil,
            &pixelBuffer
        )
        guard let pixelBuffer else {
            throw EpisodeRenderingError.couldNotCreatePixelBuffer
        }
        guard status == kCVReturnSuccess else {
            throw EpisodeRenderingError.badPixelBufferStatus
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer)
        
        let bitmapInfo = CGBitmapInfo(
            rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        )
        let context = CGContext(
            data: pixelData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: bitmapInfo.rawValue
        )
        
        guard let cgImageContext = context else {
            throw EpisodeRenderingError.couldNotCreateImageContext
        }
        let rect = CGRect(origin: .zero, size: image.size)
        
        if let coreGraphicsImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) {
            cgImageContext.draw(coreGraphicsImage, in: CGRect(origin: .zero, size: rect.size))
        } else {
            throw EpisodeRenderingError.couldNotCreateCGImage
        }
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        return pixelBuffer
    }
}
