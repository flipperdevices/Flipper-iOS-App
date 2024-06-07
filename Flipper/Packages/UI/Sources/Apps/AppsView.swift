import Core
import SwiftUI

struct AppsView: View {
    var initialSegment: AppsSegments.Segment

    @EnvironmentObject var model: Applications
    @Environment(\.dismiss) var dismiss

    @State private var predicate = ""
    @State private var showSearchView = false

    @State private var selectedSegment: AppsSegments.Segment = .all

    @Environment(\.notifications) private var notifications
    @State private var isNotConnectedAlertPresented = false

    var allSelected: Bool {
        selectedSegment == .all
    }

    var installedSelected: Bool {
        selectedSegment == .installed
    }

    init(initialSegment: AppsSegments.Segment) {
        self.initialSegment = initialSegment
    }

    var body: some View {
        ZStack {
            AllAppsView()
                .opacity(allSelected && predicate.isEmpty ? 1 : 0)

            if model.enableProgressUpdates {
                InstalledAppsView()
                    .opacity(installedSelected && predicate.isEmpty ? 1 : 0)
            }

            AppSearchView(predicate: $predicate)
                .environmentObject(model)
                .opacity(!predicate.isEmpty ? 1 : 0)
        }
        // NOTE: Fixes Error views size
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        .task {
            self.selectedSegment = initialSegment
        }
    }

    // MARK: Analytics

    func recordSearchOpened() {
        analytics.appOpen(target: .fapHubSearch)
    }
}
