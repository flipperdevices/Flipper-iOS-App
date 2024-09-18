import Core
import SwiftUI

struct AppsView: View {
    @EnvironmentObject var model: Applications
    @EnvironmentObject var update: UpdateModel
    @EnvironmentObject var router: Router
    @Environment(\.dismiss) var dismiss
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.notifications) private var notifications

    @AppStorage(.selectedTab) private var selectedTab: TabView.Tab = .device
    @AppStorage(.showAppsUpdate) var showAppsUpdate = false

    @State private var path = NavigationPath()
    @State private var selectedSegment: AppsSegments.Segment = .all

    @State private var predicate = ""
    @State private var showSearchView = false

    @State private var isNotConnectedAlertPresented = false

    var allSelected: Bool {
        selectedSegment == .all
    }

    var installedSelected: Bool {
        selectedSegment == .installed
    }

    enum Destination: Hashable {
        case app(String)
        case category(Applications.Category)
    }

    init() {
    }

    var body: some View {
        NavigationStack(path: $path) {
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
                    guard let alias = url.applicationAlias else {
                        return
                    }
                    path.append(Destination.app(alias))
                    selectedTab = .apps
                }
            }
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case .category(let category):
                    AppsCategoryView(category: category)
                case .app(let alias):
                    AppView(alias: alias)
                }
            }
            .onChange(of: update.state) { newValue in
                guard newValue == .update(.result(.succeeded)) else { return }
                showAppsUpdate = true
                showAppsUpdateIfNeeded()
            }
            .onChange(of: model.installedStatus) { newValue in
                guard newValue == .loaded else { return }
                showAppsUpdateIfNeeded()

            }
            .notification(isPresented: notifications.apps.showUpdateAvailable) {
                AppsUpdateAvailableBanner(
                    isPresented: notifications.apps.showUpdateAvailable
                )
                .environmentObject(router)
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

    func showAppsUpdateIfNeeded() {
        if model.outdatedCount > 0 {
            showAppsUpdate = false
            notifications.apps.showUpdateAvailable = true
        }
    }

    // MARK: Analytics

    func recordSearchOpened() {
        analytics.appOpen(target: .fapHubSearch)
    }
}

extension URL {
    var isApplicationURL: Bool {
        (host == "lab.flipp.dev" || host == "lab.flipper.net")
        && pathComponents.count == 3
        && pathComponents[1] == "apps"
    }

    var applicationAlias: String? {
        guard pathComponents.count == 3, !pathComponents[2].isEmpty else {
            return nil
        }
        return pathComponents[2]
    }
}
