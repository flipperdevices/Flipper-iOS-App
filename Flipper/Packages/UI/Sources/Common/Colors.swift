import SwiftUI

extension Color {
    static var black30: Color {
        .init(red: 0.67, green: 0.67, blue: 0.67)
    }

    static var black40: Color {
        .init(red: 0.57, green: 0.57, blue: 0.57)
    }

    static var background: Color {
        .init(UIColor.systemGroupedBackground)
    }

    static var groupedBackground: Color {
        .init(UIColor.secondarySystemGroupedBackground)
    }

    static var shadow: Color {
        .init(UIColor.clear)
    }
}

extension Color {
    static var keyYellow: Color {
        .init(red: 1.0, green: 0.96, blue: 0.58)
    }
}

extension UIColor {
    static var accentColor: UIColor {
        .init(red: 0.35, green: 0.62, blue: 1.0, alpha: 1)
    }
}
