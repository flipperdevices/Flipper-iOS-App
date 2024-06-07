import Core
import SwiftUI

struct AppList: View {
    @EnvironmentObject var model: Applications
    let applications: [Application]
    let isInstalled: Bool
    let showPlaceholder: Bool
    let onLoadMore: () -> Void

    init(
        applications: [Application],
        isInstalled: Bool = false,
        showPlaceholder: Bool = false,
        onLoadMore: @escaping () -> Void = {}
    ) {
        self.applications = applications
        self.isInstalled = isInstalled
        self.showPlaceholder = showPlaceholder
        self.onLoadMore = onLoadMore
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
                NavigationLink(
                    value: HubView.Destination.application(application.alias)
                ) {
                    AppRow(
                        application: application,
                        isInstalled: isInstalled
                    )
                    .onAppear {
                        if application == applications.last {
                            onLoadMore()
                        }
                    }
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
