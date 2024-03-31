import Core
import SwiftUI

struct InstalledAppsView: View {
    @EnvironmentObject var model: Applications

    var applications: [Applications.Application] {
        model.installed.sorted {
            guard
                let priority0 = model.statuses[$0.id]?.priotiry,
                let priority1 = model.statuses[$1.id]?.priotiry
            else {
                return false
            }
            guard priority0 != priority1 else {
                return $0.current.name < $1.current.name
            }
            return priority0 < priority1
        }
    }

    var outdated: [Applications.Application] {
        applications.filter { model.statuses[$0.id] == .outdated }
    }

    var isLoading: Bool {
        model.installedStatus == .loading
    }

    var noApps: Bool {
        (!isLoading && applications.isEmpty)
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

                    LazyScrollView {
                        VStack(spacing: 18) {
                            Group {
                                if model.outdatedCount > 0 {
                                    UpdateAllAppButton {
                                        updateAll()
                                    }
                                } else {
                                    UpdateAllAppButton.Placeholder()
                                }
                            }
                            .padding(.horizontal, 14)

                            Group {
                                AppList(
                                    applications: applications,
                                    isInstalled: true,
                                    showPlaceholder: isLoading
                                )
                            }
                        }
                        .padding(.vertical, 14)
                        .opacity(noApps ? 0 : 1)
                    }
                    .refreshable(isEnabled: !isLoading) {
                        reload()
                    }
                }
            }
        }
    }

    func updateAll() {
        Task {
            await model.update(outdated)
        }
    }

    func reload() {
        Task {
            try await model.loadInstalled()
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
