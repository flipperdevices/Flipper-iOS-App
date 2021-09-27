import SwiftUI

extension View {
    var iOS14: Bool {
        ProcessInfo.processInfo.operatingSystemVersion.majorVersion == 14
    }

    var onMac: Bool {
        ProcessInfo.processInfo.isiOSAppOnMac
    }

    var bottomSafeArea: Double {
        UIDevice.isFaceIDAvailable ? 34 : 0
    }

    var tabViewHeight: Double { 49 }

    var systemBackground: Color {
        .init(UIColor.systemBackground)
    }
}
