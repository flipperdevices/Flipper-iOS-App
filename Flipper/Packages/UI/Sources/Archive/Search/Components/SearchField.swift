import SwiftUI

struct SearchField: View {
    let placeholder: String
    @Binding var predicate: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .padding(.leading, 6)
                .foregroundColor(.primary.opacity(0.7))

            ZStack(alignment: .leading) {
                Text(placeholder)
                    .lineLimit(1)
                    .font(.system(size: 17))
                    .opacity(predicate.isEmpty ? 1 : 0)
                    .foregroundColor(.primary.opacity(0.7))

                TextField("", text: $predicate)
                    .lineLimit(1)
                    .submitLabelDoneIfAvailable()
                    .font(.system(size: 17))
                    .padding(.trailing, 6)
                    .padding(.vertical, 7)
            }

            Spacer()
        }
        .background(Color(red: 0.46, green: 0.46, blue: 0.5, opacity: 0.12))
        .cornerRadius(10)
    }
}
