import SwiftUI

enum InfraredLayoutState: String, CaseIterable, Equatable {
    case `default`
    case emulating
    case syncing
    case disabled
    case notSupported
}

struct InfraredLayoutStateKey: EnvironmentKey {
    static let defaultValue: InfraredLayoutState = .default
}

extension EnvironmentValues {
    var layoutState: InfraredLayoutState {
        get { self[InfraredLayoutStateKey.self] }
        set { self[InfraredLayoutStateKey.self] = newValue }
    }
}
