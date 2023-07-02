import Core
import SwiftUI

struct AppsCategoryView: View {
    @EnvironmentObject var model: Applications
    @Environment(\.dismiss) var dismiss

    let category: Applications.Category

    @State var isLoading = false
    @State var applications: [Applications.Application] = []
    @State private var sortOrder: Applications.SortOption = .default

    var body: some View {
        Group {
            if !isLoading && applications.isEmpty {
                EmptyCategoryView()
                    .padding(.horizontal, 24)
            } else {
                ScrollView {
                    VStack(spacing: 18) {
                        HStack {
                            Spacer()
                            SortMenu(selected: $sortOrder)
                        }
                        .padding(.horizontal, 14)

                        if isLoading {
                            AppRowPreview()
                        } else {
                            AppList(applications: applications)
                        }
                    }
                    .padding(.vertical, 18)
                }
            }
        }
        .background(Color.background)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LeadingToolbarItems {
                BackButton {
                    dismiss()
                }

                Title(category.name)
                    .padding(.leading, 8)
            }
        }
        .task {
            await load()
        }
        .onChange(of: sortOrder) { _ in
            Task {
                await load()
            }
        }
    }

    func load() async {
        do {
            isLoading = true
            applications = try await model.loadApplications(
                for: category,
                sort: sortOrder)
            isLoading = false
        } catch {
            applications = []
        }
    }

    struct EmptyCategoryView: View {
        @AppStorage(.selectedTabKey) var selectedTab: TabView.Tab = .device

        var body: some View {
            VStack(spacing: 8) {
                Text("No Apps Yet")

                Text("""
                    This category is empty or there are no apps for your \
                    Flipper firmware. Update Flipper firmware to the \
                    Release version to see available apps
                    """
                )
                .multilineTextAlignment(.center)
                .foregroundColor(.black40)

                Button {
                    selectedTab = .device
                } label: {
                    Text("Go to Device Screen")
                        .foregroundColor(.a2)
                }
            }
            .font(.system(size: 14, weight: .medium))
        }
    }
}
