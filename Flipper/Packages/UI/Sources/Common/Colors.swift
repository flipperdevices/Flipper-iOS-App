import SwiftUI

extension Color {
    static var black30: Color {
        .init(red: 0.67, green: 0.67, blue: 0.67)
    }

    static var black40: Color {
        .init(red: 0.57, green: 0.57, blue: 0.57)
    }

    var background: Color {
        .init(UIColor.systemBackground)
    }

    static var background: Color {
        .init(UIColor.systemBackground)
    }

    static var groupedBackground: Color {
        .init(UIColor.secondarySystemGroupedBackground)
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
    var shadowColor: Color {
        colorScheme == .dark
            ? .shadowDark
            : .shadowLight
    }
}
