import SwiftUI

struct ArchiveSearchView: View {
    @StateObject var viewModel: ArchiveSearchViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                SearchField(
                    placeholder: "Search by name and note",
                    predicate: $viewModel.predicate)

                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Cancel")
                        .font(.system(size: 18, weight: .regular))
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)

            if viewModel.filteredItems.isEmpty {
                NothingFoundView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.background)
                    .onTapGesture {
                        resignFirstResponder()
                    }
            } else {
                ScrollView {
                    CategoryList(items: viewModel.filteredItems)
                        .padding(14)
                }
            }
        }
    }
}
