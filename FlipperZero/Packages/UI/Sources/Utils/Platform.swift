import SwiftUI

extension View {
    var iOS14: Bool {
        ProcessInfo.processInfo.operatingSystemVersion.majorVersion == 14
    }

    var onMac: Bool {
        ProcessInfo.processInfo.isiOSAppOnMac
    }
}
