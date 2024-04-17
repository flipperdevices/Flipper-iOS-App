import SwiftUI

struct InAppNotifications {
    var archive: Archive = .init()
    var apps: Apps = .init()
    var notifications: Notifications = .init()

    struct Archive {
        var showImported = false
    }

    struct Apps {
        var showHidden = false
        var showReported = false
        var showUpdateAvailable = false
    }

    struct Notifications {
        var showEnabled = false
        var showDisabled = false
    }
}

extension Binding where Value == InAppNotifications {
    var archive: Value.Archive {
        get { wrappedValue.archive }
        nonmutating set { wrappedValue.archive = newValue }
    }

    var apps: Value.Apps {
        get { wrappedValue.apps }
        nonmutating set { wrappedValue.apps = newValue }
    }

    var notifications: Value.Notifications {
        get { wrappedValue.notifications }
        nonmutating set { wrappedValue.notifications = newValue }
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
