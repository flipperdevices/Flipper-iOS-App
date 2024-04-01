import Core
import SwiftUI

extension AppView {
    struct Buttons: View {
        @EnvironmentObject var model: Applications
        @EnvironmentObject var device: Device

        let application: Application

        var status: Applications.ApplicationStatus {
            if let status = model.statuses[application.id] {
                return status
            } else if model.installedStatus == .loading {
                return .checking
            } else {
                return .notInstalled
            }
        }

        var canDelete: Bool {
            switch status {
            case .installed: return true
            case .outdated: return true
            default: return false
            }
        }

        @State var confirmDelete = false
        @State var isNotConnectedAlertPresented = false
        @State var isFlipperBusyAlertPresented = false

        @State var showRemoteControl = false

        var body: some View {
            HStack(alignment: .center, spacing: 12) {
                if canDelete {
                    DeleteAppButton {
                        confirmDelete = true
                    }
                    .frame(width: 46, height: 46)
                    .alert(isPresented: $confirmDelete) {
                        ConfirmDeleteAppAlert(
                            isPresented: $confirmDelete,
                            application: application
                        ) {
                            delete()
                        }
                    }
                }

                switch status {
                case _ where model.installedStatus == .loading:
                    AnimatedPlaceholder()
                case .installing(let progress):
                    InstallingAppButton(progress: progress)
                        .font(.haxrCorpNeue(size: 36))
                case .updating(let progress):
                    UpdatingAppButton(progress: progress)
                        .font(.haxrCorpNeue(size: 36))
                case .notInstalled:
                    InstallAppButton {
                        if model.deviceInfo != nil {
                            install()
                        } else {
                            isNotConnectedAlertPresented = true
                        }
                    }
                    .font(.born2bSportyV2(size: 32))
                case .installed where !model.hasOpenAppSupport:
                    InstalledAppButton()
                        .font(.born2bSportyV2(size: 32))
                case .installed:
                    OpenAppButton(action: openApp)
                        .font(.born2bSportyV2(size: 32))
                case .opening:
                    OpeningAppButton()
                        .font(.born2bSportyV2(size: 32))
                case .outdated:
                    UpdateAppButton {
                        if model.deviceInfo != nil {
                            update()
                        } else {
                            isNotConnectedAlertPresented = true
                        }
                    }
                    .font(.born2bSportyV2(size: 32))
                case .building:
                    UpdateAppButton {
                    }
                    .font(.born2bSportyV2(size: 32))
                case .checking:
                    AnimatedPlaceholder()
                }
            }
            .frame(height: 46)
            .alert(isPresented: $isNotConnectedAlertPresented) {
                RunsOnLatestFirmwareAlert(
                    isPresented: $isNotConnectedAlertPresented)
            }
            .alert(isPresented: $isFlipperBusyAlertPresented) {
                FlipperIsBusyAlert(
                    isPresented: $isFlipperBusyAlertPresented,
                    goToRemote: goToRemoteScreen
                )
            }
            .sheet(isPresented: $showRemoteControl) {
                RemoteControlView()
                    .environmentObject(device)
                    .navigationBarHidden(true)
            }
        }

        func install() {
            recordAppInstall(application: application)
            Task {
                await model.install(application)
            }
        }

        func update() {
            Task {
                await model.update(application)
            }
        }

        func delete() {
            Task {
                await model.delete(application.id)
            }
        }

        func openApp() {
            Task {
                switch await model.openApp(application) {
                case .success: goToRemoteScreen()
                case .busy: isFlipperBusyAlertPresented = true
                case .error: break
                }
            }
        }

        func goToRemoteScreen() {
            showRemoteControl = true
        }

        // MARK: Analytics

        func recordAppInstall(application: Application) {
            analytics.appOpen(target: .fapHubInstall(application.alias))
        }
    }
}
