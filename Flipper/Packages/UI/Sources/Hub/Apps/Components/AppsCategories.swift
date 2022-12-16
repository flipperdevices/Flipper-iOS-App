import Core
import SwiftUI

struct AppsCategories: View {
    @EnvironmentObject var model: Applications
    let categories: [Applications.Category]

    var columns: [GridItem] {
        [.init(.flexible()), .init(.flexible()), .init(.flexible())]
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            if categories.isEmpty {
                ForEach(0..<9) { _ in
                    CategoryPlaceholder()
                }
            } else {
                ForEach(categories) { category in
                    NavigationLink {
                        AppsCategoryView(category: category)
                            .environmentObject(model)
                    } label: {
                        AppsCategory(category: category)
                    }
                }
            }
        }
    }

    struct CategoryPlaceholder: View {
        var body: some View {
            AnimatedPlaceholder()
                .frame(maxWidth: .infinity)
                .frame(height: 56)
        }
    }

    struct AppsCategory: View {
        let category: Applications.Category

        var body: some View {
            Card {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        CategoryIcon(url: category.icon)
                            .foregroundColor(.primary)
                            .frame(width: 18, height: 18)

                        Spacer()

                        Text("\(category.applications)")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.black60)
                    }

                    Text(category.name)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.primary)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 10)
            }
        }
    }
}
