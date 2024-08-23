import SwiftUI

struct Popups {
    var infrared: Infrared = .init()

    struct Infrared {
        var showOptions = false
    }
}

extension Binding where Value == Popups {
    var infrared: Value.Infrared {
        get { wrappedValue.infrared }
        nonmutating set { wrappedValue.infrared = newValue }
    }
}

extension EnvironmentValues {
    var popups: Binding<Popups> {
        get { self[PopupsKey.self] }
        set { self[PopupsKey.self] = newValue }
    }
}

private struct PopupsKey: EnvironmentKey {
    static let defaultValue: Binding<Popups> = .constant(.init())
}
