import Core
import SwiftUI

struct AllAppsView: View {
    @EnvironmentObject var model: Applications

    @State private var isBusy = false
    @State private var categories: [Applications.Category] = []
    @State private var applications: [Applications.ApplicationInfo] = []
    @State private var sortOrder: Applications.SortOption = .default
    @State private var error: Applications.Error?

    var body: some View {
        RefreshableScrollView(isEnabled: true) {
            reload()
        } content: {
            VStack(spacing: 0) {
                AppsCategories(categories: categories)
                    .padding(.horizontal, 14)

                if let error, error == .unknownSDK {
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
                    .padding(.top, 24)
                    .padding(.horizontal, 14)

                    AppList(applications: applications)
                        .padding(.top, 18)
                }

                if isBusy {
                    AppRowPreview()
                        .padding(.top, 12)
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
        .task {
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
            isBusy = true
            defer { isBusy = false }
            applications = try await model.loadApplications(sort: sortOrder)
        } catch let error as Applications.Error {
            self.error = error
        } catch {
            applications = []
        }
    }

    func reload() {
        error = nil
        reloadCategories()
        reloadApplications()
    }

    func reloadCategories() {
        categories = []
        Task {
            await loadCategories()
        }
    }

    func reloadApplications() {
        applications = []
        Task {
            await loadApplications()
        }
    }
}
