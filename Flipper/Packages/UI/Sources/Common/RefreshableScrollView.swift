import SwiftUI

extension View {
    @ViewBuilder
    func refreshable(
        isEnabled: Bool,
        action: @escaping @Sendable @MainActor () async -> Void
    ) -> some View {
        if isEnabled {
            self.refreshable(action: action)
        } else {
            self
        }
    }
}
