import SwiftUI

extension EnvironmentValues {
    @Entry var isEditable: Bool = true
}

extension View {
    func isEditable(_ value: Bool) -> some View {
        environment(\.isEditable, value)
    }
}
