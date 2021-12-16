import Core
import SwiftUI

struct ArchiveBinListView: View {
    var items: [ArchiveItem]
    @Binding var isSelectItemsMode: Bool
    @Binding var selectedItems: [ArchiveItem]

    var onItemSelected: (ArchiveItem) -> Void

    init(
        items: [ArchiveItem],
        isSelectItemsMode: Binding<Bool>,
        selectedItems: Binding<[ArchiveItem]>,
        onItemSelected: @escaping (ArchiveItem) -> Void
    ) {
        self.items = items
        self._isSelectItemsMode = isSelectItemsMode
        self._selectedItems = selectedItems
        self.onItemSelected = onItemSelected
    }

    var body: some View {
        ScrollView {
            ForEach(items) { item in
                Button {
                    onItemSelected(item)
                } label: {
                    HStack(spacing: 0) {
                        if isSelectItemsMode {
                            Image(systemName: selectedItems.contains(item)
                                ? "checkmark.circle.fill"
                                : "circle"
                            )
                            .padding(.trailing, 6)
                        }
                        ArchiveListItemView(item: item)
                            .foregroundColor(.primary)
                            .background(systemBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.leading, isSelectItemsMode ? 5 : 16)
                .padding(.trailing, isSelectItemsMode ? 0 : 16)
            }
            .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.1))
    }
}
