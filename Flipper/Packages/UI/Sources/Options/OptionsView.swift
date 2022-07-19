import Core
import SwiftUI

struct OptionsView: View {
    @StateObject var viewModel: OptionsViewModel

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Utils")) {
                    NavigationLink("Ping") {
                        PingView(viewModel: .init())
                    }
                    .disabled(!viewModel.isOnline)
                    NavigationLink("Stress Test") {
                        StressTestView(viewModel: .init())
                    }
                    .disabled(!viewModel.isOnline)
                    NavigationLink("Speed Test") {
                        SpeedTestView(viewModel: .init())
                    }
                    .disabled(!viewModel.isOnline)
                    NavigationLink("Logs") {
                        LogsView(viewModel: .init())
                    }
                    Button("Backup Keys") {
                        viewModel.backupKeys()
                    }
                    .disabled(!viewModel.hasKeys)
                }

                Section(header: Text("Remote")) {
                    NavigationLink("Screen Streaming") {
                        RemoteContolView(viewModel: .init())
                    }
                    NavigationLink("File Manager") {
                        FileManagerView(viewModel: .init())
                    }
                    Button("Reboot Flipper") {
                        viewModel.rebootFlipper()
                    }
                    .foregroundColor(viewModel.isOnline ? .accentColor : .gray)
                }
                .disabled(!viewModel.isOnline)

                Section(header: Text("Danger")) {
                    Button("Reset App") {
                        viewModel.resetApp()
                    }
                    .foregroundColor(.sRed)
                }

                Section {
                } footer: {
                    VStack(alignment: .center) {
                        Text("Flipper Mobile App")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.black20)
                        Text("Version: \(viewModel.appVersion)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.black40)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.top, -20)
                .padding(.bottom, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Options")
                        .font(.system(size: 20, weight: .bold))
                }
            }
        }
        .navigationViewStyle(.stack)
        .navigationBarColors(foreground: .primary, background: .a1)
    }
}
