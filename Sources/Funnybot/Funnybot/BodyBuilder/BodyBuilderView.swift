//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import Foundation
import Schwifty
import SwiftUI

struct BodyBuilderView: View {
    @EnvironmentObject var tab: TabViewModel
    @StateObject var viewModel: BodyBuilderViewModel
    
    init(character: SeriesCharacter) {
        let vm = BodyBuilderViewModel(character: character)
        _viewModel = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        VStack(spacing: .md) {
            HStack(spacing: .md) {
                Text("Body Builder").pageTitleFont()
                Spacer()
                Button("Cancel") { viewModel.cancel() }
                Button("Export") { viewModel.export() }
            }
            HStack(spacing: .md) {
                VStack(spacing: .md) {
                    FormPicker(
                        title: "Animation",
                        value: $viewModel.selectedAnimation,
                        options: viewModel.animations
                    )
                    VStack(spacing: .sm) {
                        Text("Mouth").sectionTitle()
                        FormField(title: "X", value: $viewModel.mouthXString)
                        FormField(title: "Y", value: $viewModel.mouthYString)
                        FormField(title: "Size", value: $viewModel.mouthSizeString)
                        FormPicker(
                            title: "Sprite",
                            value: $viewModel.mouthSpriteName,
                            options: viewModel.mouthSprites
                        )
                    }
                    VStack(spacing: .sm) {
                        Text("Eyes").sectionTitle()
                        FormField(title: "Modifier", value: $viewModel.eyesModifier)
                        FormField(title: "X", value: $viewModel.eyesXString)
                        FormField(title: "Y", value: $viewModel.eyesYString)
                        FormField(title: "Size", value: $viewModel.eyesSizeString)
                    }
                    Button("Update") { viewModel.update() }
                        .buttonStyle(.borderedProminent)
                        .positioned(.leading)
                    
                    Spacer()
                }
                .frame(width: 300)
                
                BodyPreview(size: viewModel.canvasSize)
                    .border(Color.red, width: 2)
                    .positioned(.leadingTop)
            }
        }
        .padding(.horizontal, .md)
        .onAppear { viewModel.tab = tab }
        .environmentObject(viewModel)
    }
}

struct BodyPreview: View {
    @EnvironmentObject var viewModel: BodyBuilderViewModel
    
    let size: CGFloat
    
    var body: some View {
        ZStack {
            Image(image: viewModel.characterSprite)
                .resizable()
                .interpolation(.none)
                .aspectRatio(contentMode: .fit)
            
            Image(image: viewModel.mouthSprite)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: viewModel.mouthSpriteSize)
                .frame(height: viewModel.mouthSpriteSize)
                .background(viewModel.mouthColor.opacity(0.2))
                .offset(x: viewModel.mouthSpriteOffsetX)
                .offset(y: viewModel.mouthSpriteOffsetY)
            
            Image(image: viewModel.eyesSprite)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: viewModel.eyesSpriteSize)
                .frame(height: viewModel.eyesSpriteSize)
                .background(viewModel.eyesColor.opacity(0.2))
                .offset(x: viewModel.eyesSpriteOffsetX)
                .offset(y: viewModel.eyesSpriteOffsetY)
        }
        .frame(width: size)
        .frame(height: size)
    }
}
