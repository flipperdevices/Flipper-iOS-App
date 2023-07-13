import Core
import SwiftUI

struct InstalledAppsView: View {
    @EnvironmentObject var model: Applications

    @State var applications: [Applications.ApplicationInfo] = []

    var outdatedApplications: [Applications.ApplicationInfo] {
        applications.filter { model.statuses[$0.id] == .outdated }
    }

    var body: some View {
        ScrollView {
            if !applications.isEmpty {
                VStack(spacing: 18) {
                    if model.outdatedCount > 0 {
                        UpdateAllAppButton {
                            for application in outdatedApplications {
                                model.update(application.id)
                            }
                        }
                        .padding(.horizontal, 14)
                    }

                    AppList(
                        applications: applications,
                        isInstalled: true)
                }
                .padding(.vertical, 14)
            } else {
                InstalledAppsPreview()
            }
        }
        .onReceive(model.$manifests) { manifest in
            Task {
                await reload()
            }
        }
        .onReceive(model.$deviceInfo) { deviceInfo in
            Task {
                await reload()
            }
        }
        .task {
            await reload()
        }
    }

    func reload() async {
        guard model.deviceInfo != nil else {
            applications = []
            return
        }
        do {
            applications = try await model.loadInstalled()
        } catch {
            applications = []
        }
    }


    struct InstalledAppsPreview: View {
        var body: some View {
            VStack(spacing: 18) {
                AnimatedPlaceholder()
                    .frame(height: 36)
                    .padding(.horizontal, 14)

                AppRowPreview(isInstalled: true)
            }
            .padding(.vertical, 14)
        }
    }
}
