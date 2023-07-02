import Core
import SwiftUI

struct AppView: View {
    @EnvironmentObject var model: Applications
    @Environment(\.dismiss) var dismiss

    @State var application: Applications.Application

    var applicationURL: URL {
        .init(string: "https://lab.flipp.dev/apps/\(application.alias)")!
    }

    var isBuildReady: Bool {
        application.current.status == .ready
    }

    var body: some View {
        ScrollView {
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
                    AppScreens(application: application)
                        .frame(height: 94)

                    if let description = application.current.description {
                        Description(description: description)
                            .padding(.horizontal, 14)
                    } else {
                        AnimatedPlaceholder()
                            .frame(height: 96)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 14)
                    }


                    if let changelog = application.current.changelog {
                        Changelog(changelog: changelog)
                            .padding(.horizontal, 14)
                    } else {
                        AnimatedPlaceholder()
                            .frame(height: 96)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 14)
                    }

                    if
                        let github = application.current.links?.source.uri,
                        let manifest = application.current.links?.manifest
                    {
                        Developer(github: github, manifest: manifest)
                            .padding(.horizontal, 14)
                    } else {
                        AnimatedPlaceholder()
                            .frame(height: 96)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 14)
                    }

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
            .padding(.vertical, 14)
        }
        .background(Color.background)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LeadingToolbarItems {
                BackButton {
                    dismiss()
                }

                Title(application.current.name)
                    .padding(.leading, 8)
            }

            TrailingToolbarItems {
                ShareButton {
                    share(applicationURL)
                }
            }
        }
        .task {
            do {
                application = try await model.loadApplication(id: application.id)
            } catch {
                print(error)
            }
        }
    }
}
