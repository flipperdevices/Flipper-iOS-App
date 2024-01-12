import Core
import SwiftUI

struct AppsView: View {
    @EnvironmentObject var model: Applications
    @Environment(\.dismiss) var dismiss

    @State private var predicate = ""
    @State private var showSearchView = false

    @State private var selectedSegment: AppsSegments.Segment = .all

    @State private var isNotConnectedAlertPresented = false

    var allSelected: Bool {
        selectedSegment == .all
    }

    var installedSelected: Bool {
        selectedSegment == .installed
    }

    var body: some View {
        ZStack {
            AllAppsView()
                .opacity(allSelected && predicate.isEmpty ? 1 : 0)

            InstalledAppsView()
                .opacity(installedSelected && predicate.isEmpty ? 1 : 0)

            AppSearchView(predicate: $predicate)
                .environmentObject(model)
                .opacity(!predicate.isEmpty ? 1 : 0)
        }
        .background(Color.background)
        .navigationBarBackground(Color.a1)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !showSearchView {
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
                        selectedSegment = .all
                        showSearchView = true
                    }
                    .analyzingTapGesture {
                        recordSearchOpened()
                    }
                }
            } else {
                PrincipalToolbarItems {
                    HStack(spacing: 14) {
                        SearchField(
                            placeholder: "App name, description",
                            predicate: $predicate
                        )

                        CancelSearchButton {
                            predicate = ""
                            showSearchView = false
                        }
                    }
                }
            }
        }
    }

    // MARK: Analytics

    func recordSearchOpened() {
        analytics.appOpen(target: .fapHubSearch)
    }
}
