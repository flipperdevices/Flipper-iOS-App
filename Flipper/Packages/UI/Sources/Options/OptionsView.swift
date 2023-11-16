import Core
import SwiftUI

struct OptionsView: View {
    @EnvironmentObject var device: Device
    @EnvironmentObject var archive: ArchiveModel
    @Environment(\.dismiss) private var dismiss

    @AppStorage(.isDebugMode) var isDebugMode = false
    @AppStorage(.isProvisioningDisabled) var isProvisioningDisabled = false
    @AppStorage(.isDevCatalog) var isDevCatalog = false

    @State private var showResetApp = false
    @State private var versionTapCount = 0

    @State private var showWidgetSettings = false

    var appVersion: String {
        Bundle.releaseVersion
    }

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
                    share(archive.backupKeys())
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
                    NavigationLink("I'm watching you") {
                        CarrierView()
                    }
                    Button("Reset App") {
                        showResetApp = true
                    }
                    .foregroundColor(.sRed)
                    .confirmationDialog("", isPresented: $showResetApp) {
                        Button("Reset App", role: .destructive) {
                            AppReset.reset()
                        }
                    }
                }
            }

            Section {
            } footer: {
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
            .padding(.top, -40)
            .padding(.bottom, 20)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LeadingToolbarItems {
                BackButton {
                    dismiss()
                }
                Title("Options")
            }
        }
        .fullScreenCover(isPresented: $showWidgetSettings) {
            TodayWidgetSettingsView()
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
