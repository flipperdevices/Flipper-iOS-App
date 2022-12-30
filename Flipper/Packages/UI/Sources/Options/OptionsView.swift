import Core
import SwiftUI

struct OptionsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var applicationService: ApplicationService
    @EnvironmentObject var flipperService: FlipperService
    @EnvironmentObject var archiveService: ArchiveService
    @Environment(\.dismiss) private var dismiss

    @AppStorage(.isDebugMode) var isDebugMode = false
    @AppStorage(.isProvisioningDisabled) var isProvisioningDisabled = false

    @State var isDeviceAvailable = false
    @State var showResetApp = false
    @State var versionTapCount = 0

    var appVersion: String { Bundle.releaseVersion }

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
                    archiveService.backupKeys()
                }
                .disabled(archiveService.items.isEmpty)
            }

            Section(header: Text("Remote")) {
                NavigationLink("Screen Streaming") {
                    RemoteControlView()
                }
                NavigationLink("File Manager") {
                    FileManagerView()
                }
                Button("Reboot Flipper") {
                    flipperService.reboot()
                }
                .foregroundColor(isDeviceAvailable ? .accentColor : .gray)
            }
            .disabled(!isDeviceAvailable)

            Section {
                Button("Widget Settings") {
                    appState.widget.showSettings = true
                }
                .foregroundColor(.primary)
            }

            Section(header: Text("Resources")) {
                Link("Forum", destination: .forum)
                Link("GitHub", destination: .github)
            }

            if isDebugMode {
                Section(header: Text("Debug")) {
                    Toggle(isOn: $isProvisioningDisabled) {
                        Text("Disable provisioning")
                    }
                    NavigationLink("I'm watching you") {
                        CarrierView()
                    }
                    Button("Reset App") {
                        showResetApp = true
                    }
                    .foregroundColor(.sRed)
                    .actionSheet(isPresented: $showResetApp) {
                        .init(title: Text("Are you sure?"), buttons: [
                            .destructive(Text("Reset App")) {
                                applicationService.reset()
                            },
                            .cancel()
                        ])
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
        .onReceive(appState.$status) { status in
            isDeviceAvailable = status.isAvailable
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
