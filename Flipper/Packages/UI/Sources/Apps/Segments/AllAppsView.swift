import Core
import SwiftUI

struct AllAppsView: View {
    @EnvironmentObject var model: Applications

    @AppStorage(.hiddenApps) var hiddenApps: Set<String> = []

    @State private var isLoading = false
    @State private var isAllLoaded = false
    @State private var categories: [Applications.Category] = []
    @State private var applications: [Application] = []
    @State private var filteredApplications: [Application] = []
    @AppStorage(.appsSortOrder)
    private var sortOrder: Applications.SortOption = .default
    @State private var error: Applications.Error?

    var body: some View {
        if error != nil {
            AppsAPIError(error: $error, action: reload)
                .padding(.horizontal, 14)
        } else {
            ScrollView {
                VStack(spacing: 0) {
                    AppsCategories(categories: categories)
                        .padding(.horizontal, 14)

                    if model.isOutdatedDevice {
                        AppsNotCompatibleFirmware()
                            .padding(.horizontal, 14)
                            .padding(.top, 32)
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

                        AppList(
                            applications: filteredApplications,
                            showPlaceholder: isLoading && !isAllLoaded
                        ) {
                            Task {
                                await loadApplications()
                            }
                        }
                        .padding(.top, 24)
                    }
                }
                .padding(.vertical, 14)
            }
            .onChange(of: sortOrder) { _ in
                onSortOrderChanged()
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
            .refreshable {
                reload()
            }
        }
    }

    func filter() {
        filteredApplications = applications.filter {
            !hiddenApps.contains($0.id)
        }
    }

    func loadCategories() async {
        do {
            categories = try await model.loadCategories()
        } catch let error as Applications.Error {
            self.error = error
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
        } catch let error as Applications.Error {
            self.error = error
        } catch {
            applications = []
        }
    }

    func reload() {
        Task {
            await reloadCategories()
            await reloadApplications()
        }
    }

    func onSortOrderChanged() {
        Task {
            guard !categories.isEmpty else {
                return
            }
            await reloadApplications()
        }
    }

    func reloadCategories() async {
        categories = []
        await loadCategories()
    }

    func reloadApplications() async {
        applications = []
        isAllLoaded = false
        await loadApplications()
    }
}
