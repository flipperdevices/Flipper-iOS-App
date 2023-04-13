import AppIntents
import Foundation

@available(iOS 16.0, *)
struct FlipperShortcuts: AppShortcutsProvider {
    static var shortcutTileColor: ShortcutTileColor = .orange

    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: SendArchivedItem(),
            phrases: [
                "\(.applicationName) send item",
                "\(.applicationName) emulate item",
                "Send item from \(.applicationName)",
                "Emulate item on \(.applicationName)",
            ]
        )
    }
}
