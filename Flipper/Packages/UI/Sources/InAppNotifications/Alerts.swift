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
    var alerts: Binding<Alerts> {
        get { self[AlertsKey.self] }
        set { self[AlertsKey.self] = newValue }
    }
}

private struct AlertsKey: EnvironmentKey {
    static let defaultValue: Binding<Alerts> = .constant(.init())
}
