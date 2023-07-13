import Core
import SwiftUI

struct AllAppsView: View {
    @EnvironmentObject var model: Applications

    @State private var isBusy = false
    @State private var applications: [Applications.ApplicationInfo] = []
    @State private var sortOrder: Applications.SortOption = .default

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                AppsCategories()
                    .padding(.horizontal, 14)

                HStack {
                    Text("All Apps")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)

                    Spacer()

                    SortMenu(selected: $sortOrder)
                }
                .padding(.top, 24)
                .padding(.horizontal, 14)

                AppList(applications: applications)
                    .padding(.top, 18)

                if isBusy {
                    AppRowPreview()
                        .padding(.top, 12)
                }
            }
            .padding(.vertical, 14)
        }
        .task {
            await load()
        }
        .onChange(of: sortOrder) { newValue in
            Task {
                await load()
            }
        }
    }

    func load() async {
        do {
            isBusy = true
            applications = try await model.loadApplications(sort: sortOrder)
            isBusy = false
        } catch {
            applications = []
        }
    }
}
