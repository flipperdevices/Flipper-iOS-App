import Core
import SwiftUI

struct WidgetAddKeyView: View {
    @EnvironmentObject var archive: ArchiveModel
    @Environment(\.dismiss) private var dismiss

    let widgetKeys: [WidgetKey]
    let onItemSelected: (WidgetKey) -> Void

    @State private var predicate = ""

    var filteredItems: [ArchiveItem] {
        archive.items.filter { item in
            guard item.isAllowed else {
                return false
            }
            guard !widgetKeys.contains(where: { $0.path == item.path }) else {
                return false
            }
            guard !predicate.isEmpty else {
                return true
            }
            return item.name.value.lowercased().contains(predicate.lowercased())
                || item.note.lowercased().contains(predicate.lowercased())
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(title: "Choose Key") {
                dismiss()
            }

            SearchField(
                placeholder: "Search by name and note",
                predicate: $predicate
            )
            .padding(.vertical, 6)
            .padding(.horizontal, 16)

            if filteredItems.isEmpty {
                NothingFoundView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .customBackground(.background)
            } else {
                ScrollView {
                    CategoryList(items: filteredItems) { item in
                        onItemSelected(.init(name: item.name, kind: item.kind))
                        dismiss()
                    }
                    .padding(14)
                }
                .customBackground(.background)
            }
        }
        .customBackground(.background)
    }
}

private extension ArchiveItem {
    var isAllowed: Bool {
        kind == .subghz || kind == .nfc || kind == .rfid || kind == .ibutton
    }
}
