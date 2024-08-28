//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import SwiftUI
import Combine
import Foundation
import Schwifty
import Yage

class SceneRenderingImpl: SceneRendering {
    @Inject private var configStorage: ConfigStorageService
    @Inject private var renderingMode: SceneRenderingModeUseCase
    @Inject private var composer: FramesToVideoComposer
    @Inject private var headlessRendering: HeadlessSceneRendering
    
    var frameTime: TimeInterval = 0.1
    var fps: TimeInterval = 10
    var sceneSize: CGSize = SceneSize.standard.size
    var sceneResolution: CGSize = VideoResolution.fullHd.size
    var videoResolution: CGSize = VideoResolution.fullHd.size
    var baseScale: CGFloat = 1
    var framesPerChunk: Int = 1
    var renderingSlots: Int = 1
    var interpolation: NSImageInterpolation = .none
    var scene: RenderableScene!
    var framesCount: Int = 0
    var startTime = Date()
    var onFrameRendered: () -> Void = {}
    
    private let tag = "SceneRenderingImpl"
    
    func render(_ scene: RenderableScene, onFrameRendered: @escaping () -> Void) async throws -> [URL] {
        prepareToStart(with: scene, onFrameRendered: onFrameRendered)
        let renderableFrames = try await prepareFrames()
        framesCount = renderableFrames.count
        let processes = chunks(frames: renderableFrames)
        let renderedChunks = try await render(processes: processes)
        let urls = sortedUrls(from: renderedChunks)
        prepareForCompletion()
        return urls
    }
    
    func prepareToStart(with scene: RenderableScene, onFrameRendered: @escaping () -> Void) {
        self.startTime = Date()
        self.scene = scene
        self.onFrameRendered = onFrameRendered
        updateConfig()
    }
    
    func prepareForCompletion() {
        scene = nil
        onFrameRendered = {}
        let elapsedTime = abs(startTime.timeIntervalSinceNow)
        let timeString = String(format: "%0.2f", elapsedTime)
        Logger.debug(tag, "Done! \(timeString)s")
    }
    
    func render(processes: [RenderableProcess]) async throws -> [[RenderedChunk]] {
        Logger.debug(tag, "Will start \(processes.count) processes")
        
        return try await withThrowingTaskGroup(of: [RenderedChunk].self, body: { group in
            for (index, process) in processes.enumerated() {
                group.addTask {
                    try await self.render(index: index, process: process)
                }
            }

            var renderedChunks: [[RenderedChunk]] = []
            for try await chunks in group {
                renderedChunks.append(chunks)
            }
            return renderedChunks
        })
    }
    
    func sortedUrls(from renderedChunks: [[RenderedChunk]]) -> [URL] {
        renderedChunks
            .flatMap { $0 }
            .sorted { chunkA, chunkB in
                if chunkA.processIndex != chunkB.processIndex {
                    return chunkA.processIndex < chunkB.processIndex
                }
                if chunkA.chunkIndex != chunkB.chunkIndex {
                    return chunkA.chunkIndex < chunkB.chunkIndex
                }
                return true
            }
            .map { $0.url }
    }
    
    func render(index: Int, process: RenderableProcess) async throws -> [RenderedChunk] {
        @Inject var frameRendering: FrameRendering
        
        Logger.debug(tag, "Started process \(index) (\(process.chunks.count) chunks)")
        
        return try await process.chunks
            .asyncThrowingMap { [weak self] chunk -> RenderedChunk? in
                guard let self else { return nil }
                let url = try await self.render(chunk: chunk, engine: frameRendering)
                return RenderedChunk(chunkIndex: chunk.chunkIndex, processIndex: chunk.processIndex, url: url)
            }
            .compactMap { $0 }
    }
    
    func render(chunk: RenderableChunk, engine: FrameRendering) async throws -> URL {
        Logger.debug(tag, "Rendering Chunk \(chunk.chunkIndex) for process \(chunk.processIndex)")
        let frames = engine.render(
            frames: chunk.frames,
            resolution: videoResolution,
            interpolation: interpolation,
            onFrameRendered: onFrameRendered
        )
        return try await composer.compose(frames: frames)
    }

    func chunks(frames: [RenderableFrame]) -> [RenderableProcess] {
        frames
            .chunks(ofSize: framesPerChunk)
            .split(numberOfParts: renderingSlots)
            .enumerated()
            .map { (processIndex, chunkedFrames) in
                let chunks = chunkedFrames
                    .enumerated()
                    .map { (chunkIndex, frames) in
                        RenderableChunk(chunkIndex: chunkIndex, processIndex: processIndex, frames: frames)
                    }
                return RenderableProcess(chunks: chunks)
            }
    }
    
    func prepareFrames() async throws -> [RenderableFrame] {
        Logger.debug(tag, "Preparing frames...")
        return try await headlessRendering.render(scene: scene, config: configStorage.current)
    }
    
    private func updateConfig() {
        let config = configStorage.current
        renderingSlots = config.renderingSlots
        baseScale = config.baseScale
        frameTime = config.frameTime
        fps = config.fps
        framesPerChunk = config.framesPerChunk
        sceneSize = config.sceneSize
        videoResolution = config.videoResolution
        sceneResolution = config.sceneSize.scaled(config.baseScale)
        interpolation = renderingMode.imageInterpolation(for: config.renderingMode)
    }
    
    private func image(named path: String) -> NSImage? {
        if let image = NSImage(named: path) {
            image
        } else if path.starts(with: "agent") {
            NSImage(size: .oneByOne)
        } else {
            nil
        }
    }
}

struct RenderableChunk {
    let chunkIndex: Int
    let processIndex: Int
    let frames: [RenderableFrame]
}

struct RenderableProcess {
    let chunks: [RenderableChunk]
}

struct RenderedChunk {
    let chunkIndex: Int
    let processIndex: Int
    let url: URL
}
