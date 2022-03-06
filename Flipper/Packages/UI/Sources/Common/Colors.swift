import SwiftUI

extension Color {
    static var black30: Color {
        .init(red: 0.67, green: 0.67, blue: 0.67)
    }

    static var black40: Color {
        .init(red: 0.57, green: 0.57, blue: 0.57)
    }

    static var backgroundLight: Color {
        .init(red: 0.98, green: 0.98, blue: 0.98)
    }

    static var secondaryBackgroundLight: Color {
        .white
    }

    static var backgroundDark: Color {
        .black
    }

    static var secondaryBackgroundDark: Color {
        .init(red: 0.05, green: 0.05, blue: 0.05)
    }

    static var shadowLight: Color {
        .init(red: 0.8, green: 0.8, blue: 0.8, opacity: 0.25)
    }

    static var shadowDark: Color {
        .init(red: 0.07, green: 0.07, blue: 0.07, opacity: 1)
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

extension EnvironmentValues {
    var secondaryBackgroundColor: Color {
        colorScheme == .dark
            ? .secondaryBackgroundDark
            : .secondaryBackgroundLight
    }

    var backgroundColor: Color {
        colorScheme == .dark
            ? .backgroundDark
            : .backgroundLight
    }

    var shadowColor: Color {
        colorScheme == .dark
            ? .shadowDark
            : .shadowLight
    }
}
