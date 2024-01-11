import Core
import SwiftUI

struct ArchiveSearchView: View {
    @EnvironmentObject var archive: ArchiveModel
    @Environment(\.dismiss) private var dismiss

    @State private var predicate = ""
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
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: 14) {
                    SearchField(
                        placeholder: "Search by name and note",
                        predicate: $predicate
                    )
                    .frame(height: 36)

                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .font(.system(size: 18, weight: .regular))
                    }
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 16)

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

            NavigationLink("", isActive: $showInfoView) {
                if let selectedItem {
                    InfoView(item: selectedItem)
                }
            }
        }
    }
}
