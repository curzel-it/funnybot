import SwiftUI

enum DesignSystem {
    enum Buttons {
        static let reducedCornerRadius: CGFloat = 4
        static let cornerRadius: CGFloat = 6
        static let borderWidth: CGFloat = 1
        static let height: CGFloat = 30
        static let iconWidth: CGFloat = 16
    }
    
    enum Checkbox {
        static let cornerRadius: CGFloat = 1
        static let borderWidth: CGFloat = 1
        static let size: CGFloat = 18
    }
    
    enum Radiobox {
        static let cornerRadius: CGFloat = 1
        static let borderWidth: CGFloat = 1
        static let size: CGFloat = 20
    }
    
    enum Popups {
        static let cornerRadius: CGFloat = 6
        static let largeCornerRadius: CGFloat = 12
        static let shadowRadius: CGFloat = 10
        static let buttonsHeight: CGFloat = 42
        static let maxWidth: CGFloat = 600
        static let listItemsHeight: CGFloat = 48
    }
    
    enum Lists {
        static let itemHeight: CGFloat = 36
    }
    
    enum TextFields {
        static let cornerRadius: CGFloat = 4
        static let height: CGFloat = 24
        static let paddingLeading: CGFloat = 4
    }
    
    enum Forms {
        static let fieldLabelWidth: CGFloat = 100
        static let longFieldLabelWidth: CGFloat = 200
    }
    
    enum Tabs {
        static let headerHeight: CGFloat = 35
        static let headerHeightBottomPadding: CGFloat = -1
        static let headerSlopeWidth: CGFloat = 18
        static let headersSpacing: CGFloat = -headerSlopeWidth * 1.8
    }
}

extension View {
    func dimBackground() -> some View {
        background(Color.black.opacity(0.2))
    }
    
    func textFieldBackground() -> some View {
        background(
            RoundedRectangle(cornerRadius: DesignSystem.TextFields.cornerRadius)
                .fill(Color.textFieldBackground)
        )
        .clipped()
    }
}

extension View {
    func quickCornerRadius() -> some View {
        clipShape(RoundedRectangle(cornerRadius: 6))
    }
    
    func smoothCornerRadius() -> some View {
        clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
