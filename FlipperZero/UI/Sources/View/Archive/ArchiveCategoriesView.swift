import SwiftUI

struct ArchiveCategoriesView: View {
    let categories: [String]
    @Binding var selectedIndex: Int
    @Namespace var animation

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { proxy in
                HStack {
                    ForEach(categories, id: \.self) {
                        ArchiveCategoryItemView(
                            title: $0,
                            animation: animation,
                            isSelected: $0 == categories[selectedIndex]
                        ) { name in
                            if let index = categories.firstIndex(of: name) {
                                self.selectedIndex = index
                                proxy.scrollTo(name, anchor: .trailing)
                            }
                        }
                        .id($0)
                    }
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
    var isSelected: Bool

    var onTapGesture: (String) -> Void

    var body: some View {
        VStack {
            Text(title)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .accentColor : .secondary)
                .onTapGesture {
                    onTapGesture(title)
                }
            Spacer()
            if isSelected {
                Color.accentColor
                    .frame(height: 3)
                    .cornerRadius(3, corners: [.topLeft, .topRight])
                    .matchedGeometryEffect(id: "ArchiveTabItem", in: animation)
            }
        }
        .padding(.horizontal, 7)
    }
}
