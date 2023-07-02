import Core
import SwiftUI

struct AppsView: View {
    @EnvironmentObject var model: Applications
    @Environment(\.dismiss) var dismiss

    @State var showSearchView: Bool = false
    @State var selectedSegment: AppsSegments.Segment = .installed

    @State var isNotConnectedAlertPresented = false

    var allSelected: Bool {
        selectedSegment == .all
    }

    var installedSelected: Bool {
        selectedSegment == .installed
    }

    var body: some View {
        ZStack {
            NavigationLink("", isActive: $showSearchView) {
                AppSearchView()
                    .environmentObject(model)
            }

            AllAppsView()
                .opacity(allSelected ? 1 : 0)

            InstalledAppsView()
                .opacity(installedSelected ? 1 : 0)
        }
        .background(Color.background)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LeadingToolbarItems {
                BackButton {
                    dismiss()
                }
            }

            PrincipalToolbarItems {
                AppsSegments(selected: $selectedSegment)
            }

            TrailingToolbarItems {
                SearchButton {
                    showSearchView = true
                }
            }
        }
    }
}
