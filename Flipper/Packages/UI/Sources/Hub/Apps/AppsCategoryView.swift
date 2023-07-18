import Core
import SwiftUI

struct AppsCategoryView: View {
    @EnvironmentObject var model: Applications
    @Environment(\.dismiss) var dismiss

    let category: Applications.Category

    @State private var isLoading = false
    @State private var applications: [Applications.ApplicationInfo] = []
    @State private var sortOrder: Applications.SortOption = .default
    @State private var apiError: Applications.APIError?

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
            } else if apiError != nil {
                AppsAPIError(error: $apiError, action: reload)
                    .padding(.horizontal, 14)
            } else {
                RefreshableScrollView(isEnabled: true) {
                    reload()
                } content: {
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
    }

    func load() async {
        do {
            isLoading = true
            applications = try await model.loadApplications(
                for: category,
                sort: sortOrder)
            isLoading = false
        } catch let error as Applications.APIError {
            apiError = error
        } catch {
            applications = []
        }
    }

    func reload() {
        applications = []
        Task {
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
