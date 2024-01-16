import Core
import SwiftUI

struct AppRow: View {
    @EnvironmentObject var model: Applications
    let application: Applications.Application
    let isInstalled: Bool

    @State private var status: Applications.ApplicationStatus = .notInstalled
    @State private var showConfirmDelete = false

    var isBuildReady: Bool {
        application.current.status == .ready
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                IconNameCategory(
                    application: application,
                    category: model.category(for: application)
                )

                Spacer()

                AppRowActionButton(
                    application: application,
                    status: status
                )
                .disabled(!isBuildReady)

                if isInstalled {
                    DeleteAppButton {
                        showConfirmDelete = true
                    }
                    .frame(width: 34, height: 34)
                    .alert(isPresented: $showConfirmDelete) {
                        ConfirmDeleteAppAlert(
                            isPresented: $showConfirmDelete,
                            application: application,
                            category: model.category(for: application)
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
        .onReceive(model.$statuses) { statuses in
            status = statuses[application.id] ?? .notInstalled
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

        let application: Applications.Application
        let status: Applications.ApplicationStatus

        @State var isNotConnectedAlertPresented = false
        @State var isFlipperBusyAlertPresented = false

        @State var showRemoteControl = false

        var body: some View {
            Group {
                switch status {
                case _ where model.installedStatus == .loading:
                    AnimatedPlaceholder()
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
                case .installed:
                    InstalledAppButton()
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
                case .canOpen:
                    OpenAppButton(action: openApp)
                case .opening:
                    OpeningAppButton()
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
                await model.openApp(by: application.id) { result in
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
