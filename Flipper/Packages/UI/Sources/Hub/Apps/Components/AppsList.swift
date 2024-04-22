import Core
import SwiftUI

struct AppList: View {
    @EnvironmentObject var model: Applications
    let applications: [Application]
    let isInstalled: Bool
    let showPlaceholder: Bool

    init(
        applications: [Application],
        isInstalled: Bool = false,
        showPlaceholder: Bool = false
    ) {
        self.applications = applications
        self.isInstalled = isInstalled
        self.showPlaceholder = showPlaceholder
    }

    struct Divider: View {
        var body: some View {
            SwiftUI.Divider()
                .padding(.horizontal, 14)
                .foregroundColor(.black4)
        }
    }

    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(applications) { application in
                NavigationLink {
                    AppView(alias: application.alias)
                        .environmentObject(model)
                } label: {
                    AppRow(
                        application: application,
                        isInstalled: isInstalled
                    )
                }
                .foregroundColor(.primary)
                .analyzingTapGesture {
                    recordApplicationOpened(application: application)
                }

                if application.id != applications.last?.id || showPlaceholder {
                    Divider()
                }
            }

            if showPlaceholder {
                AppRowPreview(isInstalled: isInstalled)
            }
        }
    }

    // MARK: Analytics

    func recordApplicationOpened(application: Application) {
        analytics.appOpen(target: .fapHubApp(application.alias))
    }
}
