import Core
import SwiftUI

struct AllAppsView: View {
    @EnvironmentObject var model: Applications

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                AppsCategories(categories: model.categories)
                    .padding(.horizontal, 14)

                HStack {
                    Text("All Apps")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)

                    Spacer()

                    SortMenu()
                }
                .padding(.top, 24)
                .padding(.horizontal, 14)

                AppList(applications: model.applications)
                    .padding(.top, 18)
            }
            .padding(.vertical, 14)
        }
    }
}
