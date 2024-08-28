//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import SwiftUI

extension View {
    func showsMessages() -> some View {
        modifier(AppMessageMod())
    }
}

struct AppMessage {
    let text: String
}

private struct AppMessageMod: ViewModifier {
    @EnvironmentObject var viewModel: AppViewModel
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $viewModel.isShowingMessage) {
                if let message = viewModel.message {
                    AppMessageView(message: message)
                        .padding(.lg)
                        .frame(width: 500)
                        .frame(maxHeight: 600)
                        .background(Color.background)
                        .interactiveDismissDisabled()
                }
            }
    }
}

struct AppMessageView: View {
    @EnvironmentObject var viewModel: AppViewModel
    
    let message: AppMessage
    
    var body: some View {
        VStack(spacing: .md) {
            DSTextView(value: Binding(get: { message.text }, set: { _ in }))
            
            HStack(spacing: .sm) {
                Spacer()
                Button("Copy to clipboard") {
                    viewModel.copyMessage()
                }
                Button("Ok") {
                    viewModel.message = nil
                }
            }
        }
    }
}
