import Core
import SwiftUI

extension AppView {
    struct Buttons: View {
        @EnvironmentObject var model: Applications
        let application: Applications.Application
        let status: Applications.ApplicationStatus

        var canDelete: Bool {
            switch status {
            case .installed: return true
            case .outdated: return true
            default: return false
            }
        }

        @State var confirmDelete = false
        @State var isNotConnectedAlertPresented = false

        var body: some View {
            HStack(alignment: .center, spacing: 12) {
                if canDelete {
                    DeleteAppButton {
                        confirmDelete = true
                    }
                    .frame(width: 46, height: 46)
                    .customAlert(isPresented: $confirmDelete) {
                        ConfirmDeleteAppAlert(
                            isPresented: $confirmDelete,
                            application: .init(application)
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
                }
            }
            .frame(height: 46)
            .customAlert(isPresented: $isNotConnectedAlertPresented) {
                RunsOnLatestFirmwareAlert(
                    isPresented: $isNotConnectedAlertPresented)
            }
        }

        func install() {
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
    }
}
