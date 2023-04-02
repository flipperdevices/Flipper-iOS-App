import AppIntents
@preconcurrency import Core
import Foundation
import SwiftUI

@available(iOS 16, *)
struct ArchivedItemEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Archived Item")
    static var defaultQuery = ArchivedItemEntityQuery()

    let id: String
    let name: String
    let kind: ArchiveItem.Kind

    var displayRepresentation: DisplayRepresentation {
        return DisplayRepresentation(
            title: "\(name)",
            subtitle: "\(subtitle)",
            image: image
        )
    }
}

@available(iOS 16, *)
extension ArchivedItemEntity {
    private var subtitle: String {
        switch kind {
        case .subghz:
            return "Sub-GHz"
        case .rfid:
            return "Rfid"
        case .nfc:
            return "NFC"
        case .infrared:
            return "IR"
        case .ibutton:
            return "iButton"
        }
    }

    private var image: DisplayRepresentation.Image {
        switch kind {
        case .subghz:
            return .init(systemName: "antenna.radiowaves.left.and.right")
        case .rfid:
            return .init(systemName: "memorychip")
        case .nfc:
            return .init(systemName: "creditcard")
        case .infrared:
            return .init(systemName: "av.remote")
        case .ibutton:
            return .init(systemName: "sensor")
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

        func entities(for identifiers: [String]) async throws -> [ArchivedItemEntity] {
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
