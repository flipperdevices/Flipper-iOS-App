import Core
import SwiftUI

struct AllAppsView: View {
    @EnvironmentObject var model: Applications

    @State private var isLoading = false
    @State private var isAllLoaded = false
    @State private var categories: [Applications.Category] = []
    @State private var applications: [Applications.ApplicationInfo] = []
    @State private var sortOrder: Applications.SortOption = .default
    @State private var apiError: Applications.APIError?

    var body: some View {
        RefreshableScrollView(isEnabled: true) {
            reload()
        } onEnd: {
            await loadApplications()
        } content: {
            VStack(spacing: 0) {
                AppsCategories(categories: categories)
                    .padding(.horizontal, 14)

                if model.isOutdatedDevice {
                    AppsNotCompatibleFirmware()
                        .padding(.horizontal, 14)
                        .padding(.top, 32)
                } else if apiError != nil {
                    AppsAPIError(error: $apiError, action: reload)
                        .padding(.horizontal, 14)
                } else {
                    HStack {
                        Text("All Apps")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)

                        Spacer()

                        SortMenu(selected: $sortOrder)
                    }
                    .padding(.top, 32)
                    .padding(.horizontal, 14)

                    AppList(applications: applications)
                        .padding(.top, 24)

                    if isLoading, !isAllLoaded {
                        AppRowPreview()
                            .padding(.top, 12)
                    }
                }
            }
            .padding(.vertical, 14)
        }
        .onChange(of: sortOrder) { newValue in
            reloadApplications()
        }
        .onReceive(model.$deviceInfo) { _ in
            reload()
        }
    }

    func loadCategories() async {
        do {
            categories = try await model.loadCategories()
        } catch {
            categories = []
        }
    }

    func loadApplications() async {
        do {
            guard !isLoading, !isAllLoaded else {
                return
            }
            isLoading = true
            defer { isLoading = false }
            let applications = try await model.loadApplications(
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
        } catch let error as Applications.APIError {
            apiError = error
        } catch {
            applications = []
        }
    }

    func reload() {
        reloadCategories()
        reloadApplications()
    }

    func reloadCategories() {
        Task {
            categories = []
            await loadCategories()
        }
    }

    func reloadApplications() {
        Task {
            applications = []
            isAllLoaded = false
            await loadApplications()
        }
    }
}
