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
                            model.delete(application.id)
                        }
                    }
                }
            }
            .padding(.horizontal, 14)

            if !isInstalled {
                AppScreens(application.current.screenshots)
                    .frame(height: 84)
                
                Text(application.current.shortDescription)
                    .font(.system(size: 12, weight: .medium))
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 14)
                    .lineLimit(2)
            }
        }
        .onReceive(model.$statuses) { statuses in
            if let status = statuses[application.id] {
                self.status = status
            }
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
                            model.install(application.id)
                        } else {
                            isNotConnectedAlertPresented = true
                        }
                    }
                case .installed:
                    InstalledAppButton()
                case .outdated:
                    UpdateAppButton {
                        if model.deviceInfo != nil {
                            model.update(application.id)
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
    }
}
