import SwiftUI

struct ArchiveSearchView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.backgroundColor) var backgroundColor
    @State var predicate = ""

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                SearchField(
                    placeholder: "Search by name and note",
                    predicate: $predicate)

                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Cancel")
                        .font(.system(size: 18, weight: .regular))
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)

            NothingFoundView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(backgroundColor)
        }
    }
}
