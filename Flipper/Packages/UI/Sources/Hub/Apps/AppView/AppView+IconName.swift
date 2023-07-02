import Core
import SwiftUI

extension AppView {
    struct IconNameCategory: View {
        @EnvironmentObject var model: Applications
        let application: Applications.Application

        var category: Applications.Category? {
            model.category(for: application)
        }

        var body: some View {
            HStack(spacing: 8) {
                AppIcon(application.current.icon)
                    .frame(width: 64, height: 64)

                VStack(alignment: .leading, spacing: 2) {
                    Text(application.current.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    HStack(alignment: .bottom, spacing: 4) {
                        CategoryIcon(category?.icon)
                            .frame(width: 18, height: 18)

                        CategoryName(category?.name)
                            .font(.system(size: 14, weight: .medium))
                    }
                }
                Spacer()
            }
        }
    }
}
