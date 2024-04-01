import Core
import SwiftUI

extension AppView {
    struct IconNameCategory: View {
        @EnvironmentObject var model: Applications
        let application: Application

        var body: some View {
            HStack(spacing: 8) {
                AppIcon(application.current.icon)
                    .frame(width: 58, height: 58)

                VStack(alignment: .leading, spacing: 2) {
                    Text(application.current.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    HStack(spacing: 4) {
                        CategoryIcon(application.category.icon.url)
                            .frame(width: 18, height: 18)

                        CategoryName(application.category.name)
                            .font(.system(size: 14, weight: .medium))
                    }
                }

                Spacer()
            }
        }
    }
}
