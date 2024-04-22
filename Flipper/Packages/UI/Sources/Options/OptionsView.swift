import Core
import Notifications

import SwiftUI

struct OptionsView: View {
    @EnvironmentObject var device: Device
    @EnvironmentObject var archive: ArchiveModel
    @Environment(\.dismiss) private var dismiss

    @AppStorage(.isDebugMode) var isDebugMode = false
    @AppStorage(.isProvisioningDisabled) var isProvisioningDisabled = false
    @AppStorage(.isDevCatalog) var isDevCatalog = false

    @State private var showWidgetSettings = false
    @State private var showRestartTheApp = false

    var isDeviceAvailable: Bool {
        device.status == .connected ||
        device.status == .synchronized
    }

    var body: some View {
        List {
            Section(header: Text("Utils")) {
                NavigationLink("Ping") {
                    PingView()
                }
                .disabled(!isDeviceAvailable)
                NavigationLink("Stress Test") {
                    StressTestView()
                }
                .disabled(!isDeviceAvailable)
                NavigationLink("Speed Test") {
                    SpeedTestView()
                }
                .disabled(!isDeviceAvailable)
                NavigationLink("Logs") {
                    LogsView()
                }
                Button("Backup Keys") {
                    Task { share(await archive.backupKeys()) }
                }
                .disabled(archive.items.isEmpty)
            }

            Section(header: Text("Remote")) {
                NavigationLink("File Manager") {
                    FileManagerView()
                }
                Button("Reboot Flipper") {
                    device.reboot()
                }
                .foregroundColor(isDeviceAvailable ? .accentColor : .gray)
            }
            .disabled(!isDeviceAvailable)

            Section {
                NotificationsToggle()

                Button("Widget Settings") {
                    showWidgetSettings = true
                }
                .foregroundColor(.primary)
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
                    NavigationLink("Report Bug") {
                        ReportBugView()
                    }
                }
            }
            .foregroundColor(.primary)

            if isDebugMode {
                Section(header: Text("Debug")) {
                    Toggle(isOn: $isProvisioningDisabled) {
                        Text("Disable provisioning")
                    }
                    .tint(.a1)
                    Toggle(isOn: $isDevCatalog) {
                        Text("Use dev catalog")
                    }
                    .tint(.a1)
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
        .fullScreenCover(isPresented: $showWidgetSettings) {
            TodayWidgetSettingsView()
        }
        .onChange(of: isDevCatalog) { _ in
            showRestartTheApp = true
        }
        .alert(isPresented: $showRestartTheApp) {
            RestartTheAppAlert(isPresented: $showRestartTheApp)
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
