import Core
import SwiftUI

extension AppView {
    struct Buttons: View {
        @EnvironmentObject var model: Applications
        @EnvironmentObject var device: Device

        let application: Applications.Application
        let status: Applications.ApplicationStatus

        var canDelete: Bool {
            switch status {
            case .installed: return true
            case .outdated: return true
            case .open: return true
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
                            application: .init(application),
                            category: model.category(for: application)
                        ) {
                            delete()
                        }
                    }
                }

                switch status {
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
                case .installed:
                    InstalledAppButton()
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
                case .open:
                    OpenAppButton(action: self.open)
                        .font(.born2bSportyV2(size: 32))
                case .opening:
                    OpeningAppButton()
                        .font(.born2bSportyV2(size: 32))
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
                    .environmentObject(self.device)
            }
        }

        func install() {
            recordAppInstall(application: application)
            Task {
                await model.install(application.id)
            }
        }

        func update() {
            Task {
                await model.update(application.id)
            }
        }

        func delete() {
            Task {
                await model.delete(application.id)
            }
        }

        func open() {
            Task {
                await model.open(application.id) { result in
                    switch result {
                    case .success:
                        goToRemoteScreen()
                    case .busy:
                        isFlipperBusyAlertPresented = true
                    case .error: ()
                    }
                }
            }
        }

        func goToRemoteScreen() {
            showRemoteControl = true
        }

        // MARK: Analytics

        func recordAppInstall(application: Applications.Application) {
            analytics.appOpen(target: .fapHubInstall(application.alias))
        }
    }
}
