import Core
import SwiftUI

struct EditingItem {
    static let none: EditingItem = .init(.none)

    var id: ArchiveItem.ID { value.id }

    var name: String
    var value: ArchiveItem

    init(_ value: ArchiveItem) {
        self.name = value.name.value
        self.value = value
    }

    var isFavorite: Bool {
        get { value.isFavorite }
        set { value.isFavorite = newValue }
    }

    var isRenamed: Bool {
        value.name.value != name
    }
}
