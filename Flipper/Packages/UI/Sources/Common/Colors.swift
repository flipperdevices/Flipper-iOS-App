import SwiftUI

extension Color {

    // MARK: Main

    static var background: Color {
        .init(UIColor.systemGroupedBackground)
    }

    static var groupedBackground: Color {
        .init(UIColor.secondarySystemGroupedBackground)
    }

    static var shadow: Color {
        .init(UIColor.clear)
    }

    // MARK: Accent

    static var a1: Color {
        .init(red: 1.0, green: 0.51, blue: 0.0)
    }

    static var a2: Color {
        .init(red: 0.35, green: 0.62, blue: 1.0)
    }

    // MARK: Black

    static var black4: Color {
        .init(red: 0.91, green: 0.91, blue: 0.91)
    }

    static var black8: Color {
        .init(red: 0.87, green: 0.87, blue: 0.87)
    }

    static var black12: Color {
        .init(red: 0.84, green: 0.84, blue: 0.84)
    }

    static var black16: Color {
        .init(red: 0.80, green: 0.80, blue: 0.80)
    }

    static var black20: Color {
        .init(red: 0.76, green: 0.76, blue: 0.76)
    }

    static var black30: Color {
        .init(red: 0.67, green: 0.67, blue: 0.67)
    }

    static var black40: Color {
        .init(red: 0.57, green: 0.57, blue: 0.57)
    }

    static var black60: Color {
        .init(red: 0.38, green: 0.38, blue: 0.38)
    }

    static var black80: Color {
        .init(red: 0.19, green: 0.19, blue: 0.19)
    }

    static var black88: Color {
        .init(red: 0.11, green: 0.11, blue: 0.11)
    }

    // MARK: Statuses

    static var sGreen: Color {
        .init(red: 0.2, green: 0.78, blue: 0.64)
    }

    static var sRed: Color {
        .init(red: 0.96, green: 0.25, blue: 0.25)
    }

    static var sYellow: Color {
        .init(red: 1.0, green: 0.81, blue: 0.37)
    }

    // MARK: Keys

    static var iButton: Color {
        .init(red: 0.88, green: 0.73, blue: 0.65)
    }

    static var rfid125: Color {
        .init(red: 1.0, green: 0.96, blue: 0.58)
    }

    static var nfc: Color {
        .init(red: 0.6, green: 0.81, blue: 1.0)
    }

    static var subGHz: Color {
        .init(red: 0.65, green: 0.96, blue: 0.75)
    }

    static var infrared: Color {
        .init(red: 1.0, green: 0.57, blue: 0.55)
    }

    static var badUSB: Color {
        .init(red: 1.0, green: 0.75, blue: 0.91)
    }
}
