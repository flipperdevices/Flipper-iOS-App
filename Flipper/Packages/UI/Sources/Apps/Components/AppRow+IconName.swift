import Core
import SwiftUI

extension AppRow {
    struct IconNameCategory: View {
        let application: Application

        var body: some View {
            HStack(spacing: 8) {
                AppIcon(application.current.icon)
                    .frame(width: 48, height: 48)

                VStack(alignment: .leading, spacing: 2) {
                    Text(application.current.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    HStack(spacing: 4) {
                        CategoryIcon(application.category.icon.url)
                            .frame(width: 14, height: 14)

                        CategoryName(application.category.name)
                            .font(.system(size: 14, weight: .medium))
                    }
                }

                Spacer()
            }
        }
    }
}
