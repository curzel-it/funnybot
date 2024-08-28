import SwiftUI

enum DSIcon {
    case close
    case radio(selected: Bool)
}

enum DSIconSize: CGFloat {
    case md = 24
    case mdLg = 28
}

extension Image {
    init(_ icon: DSIcon?, bundle: Bundle = .main) {
        self.init(icon?.filename ?? "", bundle: bundle)
    }
}

private extension DSIcon {
    var filename: String {
        switch self {
        case .close: "xmark"
        case .radio(let selected): "circle.circle\(selected ? ".fill" : "")"
        }
    }
}
