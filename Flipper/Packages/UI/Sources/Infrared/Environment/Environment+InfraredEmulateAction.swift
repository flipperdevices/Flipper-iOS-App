import Core
import SwiftUI

struct InfraredEmulateActionKey: EnvironmentKey {
    static let defaultValue: (InfraredKeyID) -> Void = { _ in }
}

extension EnvironmentValues {
    var emulateAction: (InfraredKeyID) -> Void {
        get { self[InfraredEmulateActionKey.self] }
        set { self[InfraredEmulateActionKey.self] = newValue }
    }
}
