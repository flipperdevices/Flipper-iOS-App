import Core
import SwiftUI

struct InstalledAppsView: View {
    @EnvironmentObject var model: Applications

    @State var isBusy = false
    @State var applications: [Applications.ApplicationInfo] = []

    var outdatedApplications: [Applications.ApplicationInfo] {
        applications.filter { model.statuses[$0.id] == .outdated }
    }

    var noApps: Bool {
        (!isBusy && applications.isEmpty)
    }

    var body: some View {
        ZStack {
            Group {
                if model.deviceInfo == nil {
                    NotConnected()
                } else {
                    NoApps()
                }
            }
            .opacity(noApps ? 1 : 0)

            RefreshableScrollView(isEnabled: true) {
                reload()
            } content: {
                Group {
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
                .opacity(noApps ? 0 : 1)
            }
        }
        .onReceive(model.$manifests) { manifest in
            reload()
        }
        .onReceive(model.$deviceInfo) { deviceInfo in
            reload()
        }
        .task {
            await load()
        }
    }

    func load() async {
        guard model.deviceInfo != nil else {
            applications = []
            return
        }
        do {
            isBusy = true
            applications = try await model.loadInstalled()
            isBusy = false
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

    struct NoApps: View {
        var body: some View {
            Text("No apps installed on your Flipper yet")
                .font(.system(size: 14, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.black40)
        }
    }

    struct NotConnected: View {
        var body: some View {
            VStack(spacing: 4) {
                Image("AppAlertNotConnected")

                VStack(spacing: 4) {
                    Text("Flipper is Not Connected")
                        .font(.system(size: 14, weight: .bold))

                    Text("Connect your Flipper Zero to install this app")
                        .font(.system(size: 14, weight: .medium))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black40)
                }
            }
            .padding(.horizontal, 24)
        }
    }
}
