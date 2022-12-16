import Core
import SwiftUI

struct InstalledAppsView: View {
    @EnvironmentObject var model: Applications

    var installed: [Applications.Application] {
        model.applications.filter { application in
            switch application.status {
            case .installed, .outdated: return true
            default: return false
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                UpdateAllAppButton {
                    print("Update All")
                }
                .padding(.horizontal, 14)

                AppList(applications: installed)
            }
            .padding(.vertical, 14)
        }
    }
}
