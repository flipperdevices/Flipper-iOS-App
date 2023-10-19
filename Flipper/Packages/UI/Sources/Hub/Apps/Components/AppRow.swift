import Core
import SwiftUI

struct AppRow: View {
    @EnvironmentObject var model: Applications
    let application: Applications.ApplicationInfo
    let isInstalled: Bool

    @State private var status: Applications.ApplicationStatus = .notInstalled
    @State private var showConfirmDelete = false

    var isBuildReady: Bool {
        application.current.status == .ready
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                IconNameCategory(application: application)

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
                    .customAlert(isPresented: $showConfirmDelete) {
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
        let application: Applications.ApplicationInfo
        let status: Applications.ApplicationStatus

        @State var isNotConnectedAlertPresented = false

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
                }
            }
            .frame(width: 92, height: 34)
            .font(.born2bSportyV2(size: 18))
            .customAlert(isPresented: $isNotConnectedAlertPresented) {
                FlipperIsNotConnectedAlert(
                    isPresented: $isNotConnectedAlertPresented)
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

        // MARK: Analytics

        func recordAppInstall(application: Applications.ApplicationInfo) {
            analytics.appOpen(target: .fapHubInstall(application.alias))
        }
    }
}
