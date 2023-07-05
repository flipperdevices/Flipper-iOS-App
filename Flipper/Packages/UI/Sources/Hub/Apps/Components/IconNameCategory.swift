import Core
import SwiftUI

struct IconNameCategory: View {
    @EnvironmentObject var model: Applications
    let application: Applications.Application
    let size: Size

    enum Size {
        case small
        case large
    }

    var category: Applications.Category? {
        model.category(for: application)
    }

    var iconSize: Double { size == .small ? 42 : 64 }
    var nameFontSize: Double { size == .small ? 12 : 18 }
    var categoryIconSize: Double { size == .small ? 14 : 18 }
    var categoryNameSize: Double { size == .small ? 12 : 14 }

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

            //Spacer()
        }
    }
}
