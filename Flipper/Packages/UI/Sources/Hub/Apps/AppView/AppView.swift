import Core
import SwiftUI

struct AppView: View {
    @EnvironmentObject var model: Applications
    @Environment(\.dismiss) var dismiss

    let alias: String

    @State var application: Applications.Application?

    var applicationURL: URL {
        .init(string: "https://lab.flipper.net/apps/\(alias)")!
    }

    var body: some View {
        RefreshableScrollView(isEnabled: true) {
            reload()
        } content: {
            if let application {
                LoadedAppView(application: application)
                    .padding(.vertical, 32)
            } else {
                LoadingAppView()
                    .padding(.vertical, 32)
            }
        }
        .background(Color.background)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LeadingToolbarItems {
                BackButton {
                    dismiss()
                }

                Title(application?.current.name ?? "Loading...")
                    .padding(.leading, 8)
            }

            TrailingToolbarItems {
                ShareButton {
                    share(applicationURL)
                }
            }
        }
        .task {
            await load()
        }
    }

    func load() async {
        do {
            application = try await model.loadApplication(id: alias)
        } catch {
            print(error)
        }
    }

    func reload() {
        application = nil
        Task {
            await load()
        }
    }

    struct LoadedAppView: View {
        @EnvironmentObject var model: Applications
        let application: Applications.Application

        var isBuildReady: Bool {
            application.current.status == .ready
        }

        var screenshots: [URL] {
            application.current.screenshots
        }

        var changelog: String {
            application.current.changelog
        }

        var description: String {
            application.current.description
        }

        var github: URL {
            application.current.links.source.uri
        }

        var manifest: URL {
            application.current.links.manifest
        }

        var body: some View {
            VStack(spacing: 18) {
                VStack(spacing: 12) {
                    IconNameCategory(application: application)

                    VersionSize(application: application)

                    Buttons(
                        application: application,
                        status: model.status(for: application)
                    )
                    .disabled(!isBuildReady)

                    if !isBuildReady || model.deviceInfo == nil {
                        AppStatusButton(application: application)
                    }

                    Divider()
                }
                .padding(.horizontal, 14)

                VStack(alignment: .leading, spacing: 32) {
                    AppScreens(screenshots)
                        .frame(height: 94)

                    Description(description: description)
                        .padding(.horizontal, 14)

                    Changelog(changelog: changelog)
                        .padding(.horizontal, 14)

                    Developer(github: github, manifest: manifest)
                        .padding(.horizontal, 14)

                    NavigationLink {
                        AppReportView(application: application)
                    } label: {
                        HStack {
                            Image("AppReport")

                            Text("Report an App")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(.sRed)
                        .padding(.horizontal, 14)
                    }
                }
            }
        }
    }
}

extension AppView {
    struct LoadingAppView: View {
        var body: some View {
            VStack(spacing: 18) {
                VStack(spacing: 12) {
                    IconNameCategoryPreview()
                    
                    VersionSizePreview()

                    ButtonsPreview()

                    Divider()
                }
                .padding(.horizontal, 14)

                VStack(alignment: .leading, spacing: 32) {
                    ScreensPreview()

                    Group {
                        DescriptionPreview()

                        ChangelogPreview()

                        DeveloperPreview()
                    }
                    .padding(.horizontal, 14)
                }
            }
        }
    }
    
    struct IconNameCategoryPreview: View {
        var body: some View {
            HStack(spacing: 8) {
                AnimatedPlaceholder()
                    .frame(width: 64, height: 64)
                
                VStack(alignment: .leading, spacing: 2) {
                    AnimatedPlaceholder()
                        .frame(maxWidth: .infinity)
                        .frame(height: 21)
                    
                    AnimatedPlaceholder()
                        .frame(width: 68, height: 17)
                }
            }
        }
    }
    
    struct ButtonsPreview: View {
        var body: some View {
            AnimatedPlaceholder()
                .frame(height: 46)
                .frame(maxWidth: .infinity)
        }
    }

    struct VersionSizePreview: View {
        var body: some View {
            VersionSize(application: nil)
        }
    }

    struct ScreensPreview: View {
        var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(0..<3) { _ in
                        AnimatedPlaceholder()
                            .frame(width: 189, height: 94)
                    }
                }
                .padding(.horizontal, 14)
            }
        }
    }

    struct TextBlockPreview: View {
        var body: some View {
            AnimatedPlaceholder()
                .frame(height: 96)
                .frame(maxWidth: .infinity)
        }
    }

    struct ChangelogPreview: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Changelog.Title()

                TextBlockPreview()
            }
        }
    }

    struct DescriptionPreview: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Description.Title()

                TextBlockPreview()
            }
        }
    }

    struct DeveloperPreview: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Developer.Title()

                TextBlockPreview()
            }
        }
    }
}
