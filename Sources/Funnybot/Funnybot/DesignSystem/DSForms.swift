//    ____                    __        __
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/
//                    /___/

import SwiftUI
import Combine
import Schwifty
import SwiftUI

struct FormField: View {
    let title: String
    let value: Binding<String>
    
    var body: some View {
        HStack(spacing: .md) {
            Text(title).formFieldLabel()
            TextField(title, text: value)
                .textFieldStyle(.plain)
                .frame(height: DesignSystem.TextFields.height)
                .padding(.leading, DesignSystem.TextFields.paddingLeading)
                .textFieldBackground()
        }
    }
}

struct FormTimePicker: View {
    let title: String
    let minHeight: CGFloat
    let value: Binding<Date>
    
    @State var collapsed: Bool = true
    
    init(
        title: String,
        value: Binding<Date>,
        minHeight: CGFloat? = nil
    ) {
        self.title = title
        self.minHeight = minHeight ?? 100
        self.value = value
    }
    
    var body: some View {
        HStack(spacing: .md) {
            Text(title).formFieldLabel()
            DatePicker(selection: value, displayedComponents: [.date, .hourAndMinute]) { EmptyView() }
            Spacer()
        }
    }
}

struct FormTextEditor: View {
    let title: String
    let collapsable: Bool
    let minHeight: CGFloat
    let value: Binding<String>
    
    @State var collapsed: Bool = true
    
    init(
        title: String,
        value: Binding<String>,
        collapsable: Bool = true,
        initiallyCollapsed: Bool = true,
        minHeight: CGFloat? = nil
    ) {
        self.title = title
        self.collapsable = collapsable
        self.minHeight = minHeight ?? 100
        self.value = value
        self.collapsed = collapsable && initiallyCollapsed
    }
    
    var body: some View {
        VStack(spacing: .sm) {
            HStack(spacing: .sm) {
                if collapsable {
                    Button {
                        collapsed = !collapsed
                    } label: {
                        Image(systemName: collapsed ? "chevron.right" : "chevron.down")
                            .foregroundColor(.label)
                            .frame(width: DesignSystem.Buttons.iconWidth)
                    }
                }
                
                Text(title)
                    .textAlign(.leading)
                    .lineLimit(2)
            }
            if !collapsed {
                DSTextView(value: value)
                    .frame(minHeight: minHeight)
                    .textFieldBackground()
            }
        }
    }
}

struct FormSwitch: View {
    let title: String
    let value: Binding<Bool>
    
    var body: some View {
        HStack(spacing: .md) {
            Text(title).formFieldLabel()
            Toggle("", isOn: value)
            Spacer(minLength: 0)
        }
    }
}

struct FormPicker<T: FormPickerOption>: View {
    let title: String
    let value: Binding<T>
    let options: [T]
    
    var body: some View {
        HStack(spacing: .md) {
            Text(title).formFieldLabel()
            Picker(selection: value) {
                ForEach(options, id: \.self) {
                    Text($0.description).tag($0)
                }
            } label: { EmptyView() }
        }
    }
}

protocol FormPickerOption: Hashable, CustomStringConvertible {}

struct FormUrlPicker: View {
    let title: String
    let value: Binding<URL?>
    let selectionType: FilePickerSelectionType
    
    init(title: String, for selectionType: FilePickerSelectionType, value: Binding<URL?>) {
        self.title = title
        self.value = value
        self.selectionType = selectionType
    }
    
    var body: some View {
        HStack(spacing: .md) {
            Text(title).formFieldLabel()
            Button("Select") {
                @Inject var filePicker: FilePickerUseCase
                if let url = filePicker.openSelection(for: selectionType) {
                    value.wrappedValue = url
                }
            }
            if let path = value.wrappedValue?.path() {
                Text(path)
            }
            Spacer(minLength: 0)
        }
    }
}

private extension Text {
    func formFieldLabel() -> some View {
        modifier(FormFieldLabelMod())
    }
}

private struct FormFieldLabelMod: ViewModifier {
    @Environment(\.useLongLabelsForFormFields) var longLabels: Bool
    
    private var width: CGFloat {
        longLabels ? DesignSystem.Forms.longFieldLabelWidth : DesignSystem.Forms.fieldLabelWidth
    }
    
    func body(content: Content) -> some View {
        HStack(spacing: .zero) {
            content
                .multilineTextAlignment(.leading)
                .lineLimit(2)
            Spacer(minLength: .zero)
        }
        .frame(width: width)
    }
}

struct UseLongLabelsForFormFieldsKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var useLongLabelsForFormFields: Bool {
        get { self[UseLongLabelsForFormFieldsKey.self] }
        set { self[UseLongLabelsForFormFieldsKey.self] = newValue }
    }
}
