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
        LazyVStack(spacing: 12) {
            ForEach(0..<applications.count, id: \.self) { index in
                let application = applications[index]

                NavigationLink {
                    AppView(application: application)
                        .environmentObject(model)
                } label: {
                    AppRow(
                        application: application,
                        isInstalled: isInstalled)
                }
                .foregroundColor(.primary)

                if application.id != applications.last?.id {
                    Divider()
                        .padding(.horizontal, 14)
                        .foregroundColor(.black4)
                }
            }
        }
    }
}
