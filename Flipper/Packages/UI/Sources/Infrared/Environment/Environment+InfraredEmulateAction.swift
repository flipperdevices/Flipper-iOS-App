import Core
import SwiftUI

extension EnvironmentValues {
    @Entry var emulateAction: (InfraredKeyID) -> Void = { _ in }
}
