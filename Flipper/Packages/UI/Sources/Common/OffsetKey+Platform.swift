import SwiftUI

struct OffsetKey: PreferenceKey {
    typealias Value = Double

    static var defaultValue = Double.zero

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}

extension View {
    var platformOffset: Double {
        ProcessInfo.processInfo.isiOSAppOnMac ? 28 : -14
    }
}
