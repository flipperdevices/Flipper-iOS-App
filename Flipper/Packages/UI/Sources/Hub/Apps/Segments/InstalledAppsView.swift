import Core
import SwiftUI

struct InstalledAppsView: View {
    @EnvironmentObject var model: Applications

    @State private var applications: [Applications.Application] = []

    var outdated: [Applications.Application] {
        applications.filter { model.statuses[$0.id] == .outdated }
    }

    var noApps: Bool {
        (model.installedStatus != .loading && applications.isEmpty)
    }

    var body: some View {
        Group {
            if model.isOutdatedDevice {
                AppsNotCompatibleFirmware()
                    .padding(.horizontal, 14)
            } else {
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
                                            updateAll()
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
            }
        }
        .onReceive(model.$installed) { installed in
            update(installed: installed, statuses: model.statuses)
        }
        .onReceive(model.$statuses) { statuses in
            update(installed: applications, statuses: statuses)
        }
    }

    func update(
        installed: [Applications.Application],
        statuses: [Applications.Application.ID: Applications.ApplicationStatus]
    ) {
        // TODO: improve sorting
        let sorted = installed.sorted { $0.alias < $1.alias }

        applications = []
        applications.append(contentsOf: sorted.filter {
            switch model.statuses[$0.id] {
            case .installing: return true
            default: return false
            }
        })
        applications.append(contentsOf: sorted.filter {
            switch model.statuses[$0.id] {
            case .updating: return true
            default: return false
            }
        })
        applications.append(contentsOf: sorted.filter {
            switch model.statuses[$0.id] {
            case .outdated: return true
            default: return false
            }
        })
        applications.append(contentsOf: sorted.filter { sorted in
            !applications.contains { $0.alias == sorted.alias }
        })
    }

    func updateAll() {
        Task {
            await model.update(outdated)
        }
    }

    func reload() {
        applications = []
        Task {
            try await model.loadInstalled()
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
            Text("You haven't installed any apps yet")
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
                    Text("Flipper Not Connected")
                        .font(.system(size: 14, weight: .bold))

                    Text("Connect your Flipper to see the installed apps")
                        .font(.system(size: 14, weight: .medium))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black40)
                }
            }
            .padding(.horizontal, 24)
        }
    }
}
