import Core
import SwiftUI

struct AppList: View {
    @EnvironmentObject var model: Applications
    let applications: [Applications.Application]
    let isInstalled: Bool

    init(
        applications: [Applications.Application],
        isInstalled: Bool = false
    ) {
        self.applications = applications
        self.isInstalled = isInstalled
    }

    var body: some View {
        LazyVStack(spacing: 24) {
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

                if application.id != applications.last?.id {
                    Divider()
                        .padding(.horizontal, 14)
                        .foregroundColor(.black4)
                }
            }
        }
    }
    
    // MARK: Analytics

    func recordApplicationOpened(application: Applications.Application) {
        analytics.appOpen(target: .fapHubApp(application.alias))
    }
}
