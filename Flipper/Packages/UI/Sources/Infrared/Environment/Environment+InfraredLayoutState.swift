import SwiftUI

enum InfraredLayoutState: String, CaseIterable, Equatable {
    case `default`
    case emulating
    case syncing
    case disabled
    case notSupported
}

extension EnvironmentValues {
    @Entry var layoutState: InfraredLayoutState = .default
}
