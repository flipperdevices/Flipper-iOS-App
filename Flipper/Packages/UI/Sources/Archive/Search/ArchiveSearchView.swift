import Core
import SwiftUI

struct ArchiveSearchView: View {
    @EnvironmentObject var archive: ArchiveModel
    @Environment(\.path) private var path
    @Environment(\.dismiss) private var dismiss

    @Binding var predicate: String

    var filteredItems: [ArchiveItem] {
        guard !predicate.isEmpty else {
            return archive.items
        }
        return archive.items.filter {
            $0.name.value.lowercased().contains(predicate.lowercased()) ||
            $0.note.lowercased().contains(predicate.lowercased())
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            if filteredItems.isEmpty {
                NothingFoundView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .customBackground(.background)
            } else {
                ScrollView {
                    CategoryList(items: filteredItems) { item in
                        path.append(ArchiveView.Destination.info(item))
                    }
                    .padding(14)
                }
                .customBackground(.background)
            }
        }
    }
}
