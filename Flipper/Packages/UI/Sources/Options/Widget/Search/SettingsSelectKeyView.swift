import SwiftUI

struct SettingsSelectKeyView: View {
    @StateObject var viewModel: SettingsSelectKeyViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(title: "Choose Key") {
                dismiss()
            }

            SearchField(
                placeholder: "Search by name and note",
                predicate: $viewModel.predicate
            )
            .padding(.vertical, 6)
            .padding(.horizontal, 16)

            if viewModel.filteredItems.isEmpty {
                NothingFoundView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .customBackground(.background)
            } else {
                ScrollView {
                    CategoryList(items: viewModel.filteredItems) { item in
                        viewModel.onItemSelected(item)
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
