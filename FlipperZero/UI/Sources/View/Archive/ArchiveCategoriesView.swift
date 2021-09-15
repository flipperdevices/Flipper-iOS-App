import SwiftUI

struct ArchiveCategoriesView: View {
    let categories: [String]
    @Binding var selected: String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(categories, id: \.self) {
                    Text($0)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 12)
                        .foregroundColor(Color.secondary)
                }
            }
        }
        .padding(.horizontal, 10)
    }
}
