import Core
import Notifications

import SwiftUI

struct OptionsView: View {
    @EnvironmentObject var device: Device
    @EnvironmentObject var archive: ArchiveModel
    @Environment(\.dismiss) private var dismiss

    @AppStorage(.isDebugMode) var isDebugMode = false
    @AppStorage(.isSyncingDisabled) var isSyncingDisabled = false
    @AppStorage(.isProvisioningDisabled) var isProvisioningDisabled = false
    @AppStorage(.isDevCatalog) var isDevCatalog = false
    @AppStorage(.showInfraredLibrary) var showInfraredLibrary = false

    @State private var showRestartTheApp = false

    var isDeviceAvailable: Bool {
        device.status == .connected ||
        device.status == .synchronized
    }

    enum Destination: Hashable {
        case ping
        case stressTest
        case speedTest
        case logs
        case fileManager
        case reportBug
        case infrared
    }

    var body: some View {
        List {
            Section(header: Text("Utils")) {
                NavigationLink(value: Destination.ping) {
                    Text("Ping")
                }
                .disabled(!isDeviceAvailable)
                NavigationLink(value: Destination.stressTest) {
                    Text("Stress Test")
                }
                .disabled(!isDeviceAvailable)
                NavigationLink(value: Destination.speedTest) {
                    Text("Speed Test")
                }
                .disabled(!isDeviceAvailable)
                NavigationLink(value: Destination.logs) {
                    Text("Logs")
                }
                Button("Backup Keys") {
                    Task { share(await archive.backupKeys()) }
                }
                .disabled(archive.items.isEmpty)
            }

            Section(header: Text("Remote")) {
                NavigationLink(value: Destination.fileManager) {
                    Text("File Manager")
                }
                Button("Reboot Flipper") {
                    device.reboot()
                }
                .foregroundColor(isDeviceAvailable ? .accentColor : .gray)
            }
            .disabled(!isDeviceAvailable)

            Section {
                NotificationsToggle()
            }

            Section {
                HStack {
                    Image("ListForum")
                        .renderingMode(.template)
                    Link(destination: .forum) {
                        Text("Forum")
                            .underline()
                    }
                }
                HStack {
                    Image("ListGitHub")
                        .renderingMode(.template)
                    Link(destination: .github) {
                        Text("GitHub")
                            .underline()
                    }
                }
                HStack {
                    Image("ListBug")
                        .renderingMode(.template)
                    NavigationLink(value: Destination.reportBug) {
                        Text("Report Bug")
                    }
                }
            }
            .foregroundColor(.primary)

            if isDebugMode {
                Section(header: Text("Debug")) {
                    Toggle(isOn: $isSyncingDisabled) {
                        Text("Disable automatic syncing")
                    }
                    .tint(.a1)
                    Toggle(isOn: $isProvisioningDisabled) {
                        Text("Disable provisioning")
                    }
                    .tint(.a1)
                    Toggle(isOn: $isDevCatalog) {
                        Text("Use dev catalog")
                    }
                    .tint(.a1)
                    Toggle(isOn: $showInfraredLibrary) {
                        Text("Infrared remotes library")
                    }
                    .tint(.a1)

                    #if DEBUG
                    NavigationLink(value: Destination.infrared) {
                        Text("Infrared layouts")
                    }
                    #endif
                }

                Section {
                    ResetButton()
                }
            }

            Section {
            } footer: {
                Version(isDebugMode: $isDebugMode)
            }
            .padding(.top, -40)
            .padding(.bottom, 20)
        }
        .navigationBarBackground(Color.a1)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LeadingToolbarItems {
                BackButton {
                    dismiss()
                }
            }
            PrincipalToolbarItems(alignment: .leading) {
                Title("Options")
            }
        }
        .onChange(of: isDevCatalog) { _ in
            showRestartTheApp = true
        }
        .alert(isPresented: $showRestartTheApp) {
            RestartTheAppAlert(isPresented: $showRestartTheApp)
        }
        .navigationDestination(for: Destination.self) { destination in
            switch destination {
            case .ping: PingView()
            case .stressTest: StressTestView()
            case .speedTest: SpeedTestView()
            case .logs: LogsView()
            case .fileManager: FileManagerView()
            case .reportBug: ReportBugView()
            case .infrared: InfraredDebugLayout()
            }
        }
    }
}

extension OptionsView {
    struct NotificationsToggle: View {
        @EnvironmentObject var notifications: Notifications
        @Environment(\.notifications) var inApp

        @AppStorage(.isNotificationsOn) var isNotificationsOn = false

        // @State var showSpinner: Bool = false

        var body: some View {
            Toggle(isOn: $isNotificationsOn) {
                VStack(alignment: .leading) {
                    Text("Push notifications")
                    Text("Notify about new firmware releases")
                        .font(.system(size: 12))
                        .foregroundColor(.black40)
                }
            }
            .tint(.a1)
            .onChange(of: isNotificationsOn) { newValue in
                enableNotifications(newValue)
            }
            .task {
                await reloadPermissions()
            }
        }

        func reloadPermissions() async {
            let isEnabled = await notifications.isEnabled
            if isEnabled != isNotificationsOn {
                isNotificationsOn = isEnabled
            }
        }

        func enableNotifications(_ newValue: Bool) async {
            do {
                if newValue {
                    try await notifications.enable()
                    inApp.notifications.showEnabled = true
                } else {
                    await notifications.disable()
                }
            } catch {
                isNotificationsOn = false
                inApp.notifications.showDisabled = true
            }
        }

        func enableNotifications(_ newValue: Bool) {
            Task { await enableNotifications(newValue) }
        }
    }

    struct ResetButton: View {
        @State private var showResetApp = false

        var body: some View {
            Button("Reset App") {
                showResetApp = true
            }
            .foregroundColor(.sRed)
            .confirmationDialog("", isPresented: $showResetApp) {
                Button("Reset App", role: .destructive) {
                    Task { await AppReset.reset() }
                }
            }
        }
    }

    struct Version: View {
        @Binding var isDebugMode: Bool

        @State private var versionTapCount = 0

        var appVersion: String {
            Bundle.releaseVersion
        }

        var body: some View {
            VStack(alignment: .center) {
                Text("Flipper Mobile App")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.black20)
                Text("Version: \(appVersion)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.black40)
            }
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .onTapGesture {
                onVersionTapGesture()
            }
        }

        func onVersionTapGesture() {
            versionTapCount += 1
            if versionTapCount == 10 {
                isDebugMode = true
                versionTapCount = 0
            }
        }
    }
}
