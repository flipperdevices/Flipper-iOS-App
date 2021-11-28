import SwiftUI

struct ViewOffsetKey: PreferenceKey {
    static var defaultValue = 0.0

    static func reduce(value: inout Double, nextValue: () -> Double) {
        value += nextValue()
    }
}
