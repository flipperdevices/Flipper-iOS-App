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
                            application: application
                        ) {
                            model.delete(application)
                        }
                    }
                }

                switch status {
                case .installing(let progress):
                    InstallingAppButton(progress: progress)
                        .font(.haxrCorpNeue(size: 36))
                case .updating(let progress):
                    InstallingAppButton(progress: progress)
                        .font(.haxrCorpNeue(size: 36))
                case .notInstalled:
                    InstallAppButton {
                        if model.deviceInfo != nil {
                            model.install(application)
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
                            model.update(application)
                        } else {
                            isNotConnectedAlertPresented = true
                        }
                    }
                    .font(.born2bSportyV2(size: 32))
                case .unknown:
                    AnimatedPlaceholder()
                }
            }
            .frame(height: 46)
            .customAlert(isPresented: $isNotConnectedAlertPresented) {
                FlipperIsNotConnectedAlert(
                    isPresented: $isNotConnectedAlertPresented)
            }
        }
    }
}
