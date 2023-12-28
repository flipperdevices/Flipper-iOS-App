import Core
import SwiftUI

struct AppsCategoryView: View {
    @EnvironmentObject var model: Applications
    @Environment(\.dismiss) var dismiss

    @AppStorage(.hiddenAppsKey) var hiddenApps: Set<String> = []

    let category: Applications.Category

    @State private var isLoading = false
    @State private var isAllLoaded = false
    @State private var applications: [Applications.Application] = []
    @State private var filteredApplications: [Applications.Application] = []
    @State private var sortOrder: Applications.SortOption = .default
    @State private var error: Applications.Error?

    var isEmpty: Bool {
        !isLoading && applications.isEmpty
    }

    var body: some View {
        ZStack {
            EmptyCategoryView()
                .padding(.horizontal, 24)
                .opacity(isEmpty ? 1 : 0)

            if model.isOutdatedDevice {
                AppsNotCompatibleFirmware()
                    .padding(.horizontal, 14)
            } else if error != nil {
                AppsAPIError(error: $error, action: reload)
                    .padding(.horizontal, 14)
            } else {
                RefreshableScrollView(isEnabled: true) {
                    reload()
                } onEnd: {
                    await load()
                } content: {
                    VStack(spacing: 18) {
                        HStack {
                            Spacer()
                            SortMenu(selected: $sortOrder)
                        }
                        .padding(.horizontal, 14)

                        AppList(applications: filteredApplications)

                        if isLoading, !isAllLoaded {
                            AppRowPreview()
                        }
                    }
                    .padding(.vertical, 18)
                }
                .opacity(!isEmpty ? 1 : 0)
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
        .onChange(of: sortOrder) { _ in
            reload()
        }
        .onReceive(model.$deviceInfo) { _ in
            reload()
        }
        .onChange(of: applications) { _ in
            Task { filter() }
        }
        .onChange(of: hiddenApps) { _ in
            Task { filter() }
        }
    }

    func filter() {
        filteredApplications = applications.filter {
            !hiddenApps.contains($0.id)
        }
    }

    func load() async {
        do {
            guard !isLoading, !isAllLoaded else {
                return
            }
            isLoading = true
            defer { isLoading = false }
            let applications = try await model.loadApplications(
                for: category,
                sort: sortOrder,
                skip: applications.count
            ).filter { application in
                !self.applications.contains { $0.id == application.id }
            }
            guard !applications.isEmpty else {
                isAllLoaded = true
                return
            }
            self.applications.append(contentsOf: applications)
        } catch let error as Applications.Error {
            self.error = error
        } catch {
            applications = []
        }
    }

    func reload() {
        Task {
            isAllLoaded = false
            applications = []
            await load()
        }
    }

    struct EmptyCategoryView: View {
        var body: some View {
            VStack(spacing: 8) {
                Text("No Apps Yet")

                Text(
                    "This category is empty or there are no apps " +
                    "for your Flipper firmware"
                )
                .multilineTextAlignment(.center)
                .foregroundColor(.black40)
            }
            .font(.system(size: 14, weight: .medium))
        }
    }
}
