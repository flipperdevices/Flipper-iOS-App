import SwiftUI

struct ArchiveCategoriesView: View {
    let categories: [String]
    @Binding var selected: String
    @Namespace var animation

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(categories, id: \.self) {
                    ArchiveCategoryItemView(
                        title: $0,
                        animation: animation,
                        selected: _selected)
                }
            }
        }
        .frame(height: 38)
        .padding(.horizontal, 10)
        .padding(.top, 10)
        .animation(.interactiveSpring())
    }
}

struct ArchiveCategoryItemView: View {
    let title: String
    let animation: Namespace.ID
    @Binding var selected: String

    var body: some View {
        VStack {
            Text(title)
                .foregroundColor(selected == title ? .accentColor : .secondary)
                .onTapGesture {
                    self.selected = title
                }
            Spacer()
            if title == selected {
                Color.accentColor
                    .frame(height: 3)
                    .cornerRadius(3, corners: [.topLeft, .topRight])
                    .matchedGeometryEffect(id: "ArchiveTabItem", in: animation)
            }
        }
        .padding(.horizontal, 7)
    }
}
