import Core
import SwiftUI

struct ArchiveSearchView: View {
    @EnvironmentObject var archive: ArchiveModel
    @Environment(\.dismiss) private var dismiss

    @Binding var predicate: String

    @State private var selectedItem: ArchiveItem?
    @State private var showInfoView = false

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
                        selectedItem = item
                        showInfoView = true
                    }
                    .padding(14)
                }
                .customBackground(.background)
            }
        }
        .background {
            NavigationLink("", isActive: $showInfoView) {
                if let selectedItem {
                    InfoView(item: selectedItem)
                }
            }
        }
    }
}
