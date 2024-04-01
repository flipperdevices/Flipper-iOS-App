import Core
import SwiftUI

struct InstalledAppsView: View {
    @EnvironmentObject var model: Applications

    var applications: [Application] {
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

    var isLoading: Bool {
        model.installedStatus == .loading
    }

    var isNetworkIssue: Bool {
        model.installedStatus == .error
    }

    var noApps: Bool {
        (!isLoading && applications.isEmpty)
    }

    struct NetworkIssue: View {
        var body: some View {
            VStack(alignment: .center) {
                Text("Unable to browse apps due to network issues")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.sRed)
            }
            .frame(height: 38)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.sRed.opacity(0.1))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.sRed.opacity(0.3), lineWidth: 1)
            }
        }
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
                                if isNetworkIssue {
                                    NetworkIssue()
                                } else if model.outdatedCount > 0 {
                                    UpdateAllAppButton {
                                        updateAll()
                                    }
                                } else {
                                    UpdateAllAppButton.Placeholder()
                                }
                            }
                            .padding(.horizontal, 14)

                            AppList(
                                applications: applications,
                                isInstalled: true,
                                showPlaceholder: isLoading
                            )
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
            await model.update(model.outdated)
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
