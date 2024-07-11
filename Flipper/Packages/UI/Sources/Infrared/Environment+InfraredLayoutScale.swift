import SwiftUI

struct InfraredLayoutScaleKey: EnvironmentKey {
    static let defaultValue: Double = 0.0
}

extension EnvironmentValues {
    var layoutScaleFactor: Double {
        get { self[InfraredLayoutScaleKey.self] }
        set { self[InfraredLayoutScaleKey.self] = newValue }
    }
}
