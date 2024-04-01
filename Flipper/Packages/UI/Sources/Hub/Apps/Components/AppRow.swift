import Core
import SwiftUI

struct AppRow: View {
    @EnvironmentObject var model: Applications
    let application: Application
    let isInstalled: Bool

    @State private var showConfirmDelete = false

    var isBuildReady: Bool {
        application.current.status == .ready
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                IconNameCategory(application: application)

                Spacer()

                AppRowActionButton(application: application)
                    .disabled(!isBuildReady)

                if isInstalled {
                    DeleteAppButton {
                        showConfirmDelete = true
                    }
                    .frame(width: 34, height: 34)
                    .alert(isPresented: $showConfirmDelete) {
                        ConfirmDeleteAppAlert(
                            isPresented: $showConfirmDelete,
                            application: application
                        ) {
                            delete()
                        }
                    }
                }
            }
            .padding(.horizontal, 14)

            if !isInstalled {
                Text(application.current.shortDescription)
                    .font(.system(size: 14, weight: .medium))
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 14)
                    .lineLimit(2)

                AppScreens(application.current.screenshots)
                    .frame(height: 84)
            }
        }
    }

    func delete() {
        Task {
            await model.delete(application.id)
        }
    }

    struct AppRowActionButton: View {
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

        @State var isNotConnectedAlertPresented = false
        @State var isFlipperBusyAlertPresented = false

        @State var showRemoteControl = false

        var body: some View {
            Group {
                switch status {
                case .installing(let progress):
                    InstallingAppButton(progress: progress)
                        .font(.haxrCorpNeue(size: 28))
                case .updating(let progress):
                    UpdatingAppButton(progress: progress)
                        .font(.haxrCorpNeue(size: 28))
                case .notInstalled:
                    InstallAppButton {
                        if model.deviceInfo != nil {
                            install()
                        } else {
                            isNotConnectedAlertPresented = true
                        }
                    }
                case .installed where !model.hasOpenAppSupport:
                    InstalledAppButton()
                case .installed:
                    OpenAppButton(action: openApp)
                case .opening:
                    OpeningAppButton()
                case .outdated:
                    UpdateAppButton {
                        if model.deviceInfo != nil {
                            update()
                        } else {
                            isNotConnectedAlertPresented = true
                        }
                    }
                case .building:
                    UpdateAppButton {
                    }
                    .disabled(true)
                case .checking:
                    AnimatedPlaceholder()
                }
            }
            .frame(width: 92, height: 34)
            .font(.born2bSportyV2(size: 18))
            .alert(isPresented: $isNotConnectedAlertPresented) {
                FlipperIsNotConnectedAlert(
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
