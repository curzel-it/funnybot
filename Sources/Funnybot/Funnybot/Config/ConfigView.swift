//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Combine
import AskGpt
import Schwifty
import SwiftUI
import Swinject

struct ConfigView: View {
    @EnvironmentObject private var tab: TabViewModel
    @StateObject private var viewModel: ConfigViewModel
    
    init(config: Config) {
        let vm = ConfigViewModel(config: config)
        _viewModel = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: .lg) {
                    HStack(spacing: .md) {
                        Text("Profile: \(viewModel.name)").pageTitleFont()
                        Spacer()                        
                        Button("Delete") {
                            viewModel.delete()
                        }
                    }
                    ConfigName()
                    FilesConfig()
                    RenderingConfig()
                    ScriptConfig()
                }
                .padding(.horizontal, .md)
                
                Spacer()
            }
        }
        .onAppear { viewModel.tab = tab }
        .environment(\.useLongLabelsForFormFields, true)
        .environmentObject(viewModel)
    }
}

private struct ConfigName: View {
    @EnvironmentObject var viewModel: ConfigViewModel
    
    var body: some View {
        FormField(title: "Name", value: $viewModel.name)
    }
}

private struct FilesConfig: View {
    @EnvironmentObject var viewModel: ConfigViewModel
    
    var body: some View {
        VStack(spacing: .sm) {
            Text("Working files").sectionTitle()
            FormUrlPicker(title: "Assets Folder", for: .folders, value: $viewModel.assetsFolder)
            FormUrlPicker(title: "Dubs Folder", for: .folders, value: $viewModel.dubsFolder)
            FormUrlPicker(title: "Videos Folder", for: .folders, value: $viewModel.videosFolder)
        }
    }
}

private struct RenderingConfig: View {
    @EnvironmentObject var viewModel: ConfigViewModel
    
    var body: some View {
        VStack(spacing: .sm) {
            Text("Rendering").sectionTitle()
            FormField(title: "Video FPS", value: $viewModel.fps)
            FormField(title: "Animations FPS", value: $viewModel.animationsFps)
            FormField(title: "Chunk Size", value: $viewModel.framesPerChunk)
            FormField(title: "Camera Transition Duration", value: $viewModel.cameraTransitionDuration)
            FormField(title: "Camera Insets (⬆️⬅️⬇️➡️)", value: $viewModel.cameraInsets)
            FormField(title: "Rendering Slots", value: $viewModel.renderingSlots)
            FormPicker(title: "Rendering Mode", value: $viewModel.renderingMode, options: SceneRenderingMode.allCases)
            FormPicker(title: "Video Resolution", value: $viewModel.videoResolution, options: VideoResolution.allCases)
            FormPicker(title: "Scene Size", value: $viewModel.sceneSize, options: SceneSize.allCases)
            FormPicker(title: "Voice Engine", value: $viewModel.voiceEngine, options: VoiceEngine.allCases)
            FormField(title: "Ground Level %", value: $viewModel.yMultiplierVerticalMid)
        }
    }
}

private struct ScriptConfig: View {
    @EnvironmentObject var viewModel: ConfigViewModel
    
    var body: some View {
        VStack(spacing: .sm) {
            Text("Script").sectionTitle()
            FormPicker(title: "Camera Mode", value: $viewModel.cameraMode, options: CameraMode.allCases)
            FormSwitch(title: "Auto character placement", value: $viewModel.autoCharacterPlacement)
            FormSwitch(title: "Auto turn to actions", value: $viewModel.autoTurnToAction)
            FormField(title: "Language", value: $viewModel.language)
        }
    }
}
