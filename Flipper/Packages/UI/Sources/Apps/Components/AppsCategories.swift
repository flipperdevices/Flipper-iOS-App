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
                    NavigationLink(
                        value: AppsView.Destination.category(category)
                    ) {
                        AppsCategory(category: category)
                    }
                    .analyzingTapGesture {
                        recordCategoryOpened(category: category)
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
                        CategoryIcon(category.icon, fixme: true)
                            .foregroundColor(.primary)
                            .frame(width: 18, height: 18)

                        Spacer()

                        Text("\(category.applications)")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.black16Black60)
                    }

                    Text(category.name)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 10)
            }
        }
    }

    // MARK: Analytics

    func recordCategoryOpened(category: Applications.Category) {
        analytics.appOpen(target: .fapHubCategory(category.name))
    }
}
