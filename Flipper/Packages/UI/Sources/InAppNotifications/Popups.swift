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
    @Entry var popups: Binding<Popups> = .constant(.init())
}
