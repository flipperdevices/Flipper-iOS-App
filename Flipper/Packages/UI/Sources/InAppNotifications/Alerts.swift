import SwiftUI

struct Alerts {
    var device: Device = .init()

    struct Device {
        var showConfirmUpdate = false
        var showUpdateSuccess = false
        var showUpdateFailure = false
    }
}

extension EnvironmentValues {
    @Entry var alerts: Binding<Alerts> = .constant(.init())
}
