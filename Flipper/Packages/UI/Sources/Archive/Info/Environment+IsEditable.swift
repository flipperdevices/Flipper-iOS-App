import SwiftUI

struct EditableKey: EnvironmentKey {
    static let defaultValue: Bool = true
}

extension EnvironmentValues {
    var isEditable: Bool {
        get { self[EditableKey.self] }
        set { self[EditableKey.self] = newValue }
    }
}

extension View {
    func isEditable(_ value: Bool) -> some View {
        environment(\.isEditable, value)
    }
}
