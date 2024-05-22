import Core
import SwiftUI

struct AppsView: View {
    @EnvironmentObject var model: Applications
    @EnvironmentObject var router: Router
    @Environment(\.dismiss) var dismiss
    @Environment(\.scenePhase) var scenePhase

    @AppStorage(.selectedTab) private var selectedTab: TabView.Tab = .device

    @State private var selectedSegment: AppsSegments.Segment = .all

    @State private var predicate = ""
    @State private var showSearchView = false

    @State private var sharedApp: SharedApp = .init()

    struct SharedApp {
        var alias: String?
        var show = false
    }

    @State private var isNotConnectedAlertPresented = false

    var allSelected: Bool {
        selectedSegment == .all
    }

    var installedSelected: Bool {
        selectedSegment == .installed
    }

    init() {
    }

    var body: some View {
        NavigationStack {
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !showSearchView {
                    LeadingToolbarItems {
                        SearchButton { }
                            .opacity(0)
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
            .onReceive(router.showApps) {
                selectedSegment = .installed
                selectedTab = .apps
            }
            .onOpenURL { url in
                if url.isApplicationURL {
                    sharedApp.alias = url.applicationAlias
                    selectedTab = .apps
                    sharedApp.show = true
                }
            }
            .navigationDestination(isPresented: $sharedApp.show) {
                if let alias = sharedApp.alias {
                    AppView(alias: alias)
                }
            }
            .onChange(of: scenePhase) { phase in
                switch phase {
                case .active: model.enableProgressUpdates = true
                case .inactive: model.enableProgressUpdates = false
                case .background: break
                @unknown default: break
                }
            }
        }
    }

    // MARK: Analytics

    func recordSearchOpened() {
        analytics.appOpen(target: .fapHubSearch)
    }
}
