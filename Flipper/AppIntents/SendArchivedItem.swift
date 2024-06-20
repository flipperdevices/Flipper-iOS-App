import AppIntents
@preconcurrency import Core
import Foundation

@available(iOS 16, *)
struct SendArchivedItem: AppIntent {
    static let title: LocalizedStringResource = "Emulate/Send archived item"
    static let description: IntentDescription = .init(
        "Use your flipper to send or emulate an item from your archive.",
        categoryName: "Archive"
    )

    static var parameterSummary: some ParameterSummary {
        Summary("Emulate/Send \(\.$archivedItem)")
    }

    private let dependencies = Dependencies.shared

    @Parameter(
        title: "Archived item",
        description: "An item archived on your Flipper.",
        requestValueDialog: "Pick an item to Emulate/Send"
    )
    var archivedItem: ArchivedItemEntity

    func perform() async throws -> some ProvidesDialog {
        guard let item = await dependencies.archiveModel.items.first(
            where: { $0.id.description == archivedItem.id }
        ) else {
            return .result(dialog:
                "\(archivedItem.name) not found in your Flipper archive."
            )
        }

        guard await dependencies.device.status == .connected else {
            return .result(dialog:
                """
                Unable to connect to Flipper. Make sure Bluetooth is \
                enabled both on this phone and on your Flipper.
                """
            )
        }

        await dependencies.emulate.startEmulate(item)
        try await Task.sleep(milliseconds: item.duration)

        guard await dependencies.emulate.state != .locked else {
            return .result(dialog:
                "Flipper is busy. Please exit any running app and try again."
            )
        }

        if [.rfid, .nfc, .ibutton].contains(item.kind) {
            return .result(dialog: "Started \(archivedItem.name) emulation.")
        }

        await dependencies.emulate.stopEmulate()
        return .result(dialog: "\(archivedItem.name) successfully sent.")
    }
}
