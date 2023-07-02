import Core
import SwiftUI

struct AppRow: View {
    @EnvironmentObject var model: Applications
    let application: Applications.Application
    let isInstalled: Bool

    @State private var showConfirmDelete = false

    var isBuildReady: Bool {
        application.current.status == .ready
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                IconNameCategory(
                    application: application,
                    size: .small)

                Spacer()

                AppRowActionButton(
                    application: application,
                    status: model.status(for: application)
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
                            model.delete(application)
                        }
                    }
                }
            }
            .padding(.horizontal, 14)

            if !isInstalled {
                AppScreens(application: application)
                    .frame(height: 84)
                
                Text(application.current.shortDescription)
                    .font(.system(size: 12, weight: .medium))
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 14)
                    .lineLimit(2)
            }
        }
    }

    struct AppRowActionButton: View {
        @EnvironmentObject var model: Applications
        let application: Applications.Application
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
                            model.install(application)
                        } else {
                            isNotConnectedAlertPresented = true
                        }
                    }
                case .installed:
                    InstalledAppButton()
                case .outdated:
                    UpdateAppButton {
                        if model.deviceInfo != nil {
                            model.update(application)
                        } else {
                            isNotConnectedAlertPresented = true
                        }
                    }
                case .unknown:
                    AnimatedPlaceholder()
                        .frame(width: 92)
                }
            }
            .frame(width: 92, height: 34)
            .font(.born2bSportyV2(size: 18))
            .customAlert(isPresented: $isNotConnectedAlertPresented) {
                FlipperIsNotConnectedAlert(
                    isPresented: $isNotConnectedAlertPresented)
            }
        }
    }
}
