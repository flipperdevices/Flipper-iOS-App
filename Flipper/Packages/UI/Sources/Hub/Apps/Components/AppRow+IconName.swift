import Core
import SwiftUI

extension AppRow {
    struct IconNameCategory: View {
        @EnvironmentObject var model: Applications
        let application: Applications.Application

        var category: Applications.Category? {
            model.category(for: application)
        }

        var body: some View {
            HStack(spacing: 8) {
                AppIcon(application.current.icon)
                    .frame(width: 42, height: 42)

                VStack(alignment: .leading, spacing: 2) {
                    Text(application.current.name)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    HStack(spacing: 4) {
                        CategoryIcon(category?.icon)
                            .frame(width: 14, height: 14)

                        CategoryName(category?.name)
                            .font(.system(size: 12, weight: .medium))
                    }
                }

                Spacer()
            }
        }
    }

}
