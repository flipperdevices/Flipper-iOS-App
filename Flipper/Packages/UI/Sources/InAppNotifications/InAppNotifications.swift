import SwiftUI

struct InAppNotifications {
    var archive: Archive = .init()

    struct Archive {
        var showImported = false
    }
}

extension Binding where Value == InAppNotifications {
    var archive: Value.Archive {
        get { wrappedValue.archive }
        nonmutating set { wrappedValue.archive = newValue }
    }
}

extension EnvironmentValues {
    var notifications: Binding<InAppNotifications> {
        get { self[InAppNotificationsKey.self] }
        set { self[InAppNotificationsKey.self] = newValue }
    }
}

private struct InAppNotificationsKey: EnvironmentKey {
    static let defaultValue: Binding<InAppNotifications> = .constant(.init())
}

private struct NotificationShowArchiveImportedKey: EnvironmentKey {
    static let defaultValue: Binding<Bool> = .constant(.init())
}
