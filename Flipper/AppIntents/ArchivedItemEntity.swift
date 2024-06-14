import AppIntents
@preconcurrency import Core
import Foundation
import SwiftUI

@available(iOS 16, *)
struct ArchivedItemEntity: AppEntity {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(
        name: "Archived Item"
    )

    static let defaultQuery = ArchivedItemEntityQuery()

    let id: String
    let name: String
    let kind: ArchiveItem.Kind

    var displayRepresentation: DisplayRepresentation {
        return DisplayRepresentation(
            title: "\(name)",
            subtitle: "\(subtitle)",
            image: .init(named: image, isTemplate: true)
        )
    }
}

@available(iOS 16, *)
extension ArchivedItemEntity {
    private var subtitle: String {
        switch kind {
        case .subghz: "Sub-GHz"
        case .rfid: "Rfid"
        case .nfc: "NFC"
        case .infrared: "IR"
        case .ibutton: "iButton"
        }
    }

    private var image: String {
        switch kind {
        case .subghz: "subghz"
        case .rfid: "rfid"
        case .nfc: "nfc"
        case .infrared: "infrared"
        case .ibutton: "ibutton"
        }
    }
}

@available(iOS 16, *)
extension ArchivedItemEntity {
    struct ArchivedItemEntityQuery: EntityQuery {
        private let dependencies = Dependencies.shared

        private var items: [ArchiveItem] {
            get async { await dependencies.archiveModel.items }
        }

        func entities(
            for identifiers: [String]
        ) async throws -> [ArchivedItemEntity] {
            await items
                .filter {
                    identifiers.contains($0.id.description)
                }
                .map {
                    .init(
                        id: $0.id.description,
                        name: $0.name.value,
                        kind: $0.kind
                    )
                }
        }

        func suggestedEntities() async throws -> [ArchivedItemEntity] {
            await items.map {
                .init(
                    id: $0.id.description,
                    name: $0.name.value,
                    kind: $0.kind
                )
            }
        }
    }
}
