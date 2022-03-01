import SwiftUI

struct ArchiveSearchView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    @State var predicate = ""

    var backgroundColor: Color {
        colorScheme == .dark
            ? .backgroundDark
            : .backgroundLight
    }

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

            ScrollView {
            }
            .background(backgroundColor)
        }
    }
}
