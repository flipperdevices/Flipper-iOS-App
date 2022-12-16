import Core
import SwiftUI
import MarkdownUI

struct AppView: View {
    @EnvironmentObject var model: Applications
    @Environment(\.dismiss) var dismiss

    let application: Applications.Application

    var canDelete: Bool {
        switch application.status {
        case .installed: return true
        case .outdated: return true
        default: return false
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                VStack(spacing: 12) {
                    IconNameCategory(application: application)

                    VersionSizeAPI(application: application)

                    HStack(spacing: 12) {
                        if canDelete {
                            DeleteAppButton {
                                model.delete(application)
                            }
                        }

                        ShareAppButton {
                            share("application")
                        }

                        switch application.status {
                        case .notInstalled:
                            InstallAppButton {
                                model.install(application)
                            }
                        case .outdated:
                            UpdateAppButton {
                                model.update(application)
                            }
                        case .installed:
                            InstalledAppButton()
                        default:
                            Text(String(describing: application.status))
                        }
                    }

                    Divider()
                }
                .padding(.horizontal, 14)

                VStack(alignment: .leading, spacing: 24) {
                    AppScreens(application: application)
                        .frame(height: 94)

                    Description(description: application.description)
                        .padding(.horizontal, 14)

                    Changelog(changelog: application.changelog)
                        .padding(.horizontal, 14)

                    Developer()
                        .padding(.horizontal, 14)
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

                Title(application.name)
                    .padding(.leading, 8)
            }
        }
    }

    struct IconNameCategory: View {
        let application: Applications.Application

        var body: some View {
            HStack(spacing: 8) {
                AppIcon(url: application.icon)
                    .frame(width: 64, height: 64)

                VStack(alignment: .leading, spacing: 2) {
                    Text(application.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    HStack(alignment: .bottom, spacing: 4) {
                        CategoryIcon(url: application.category.icon)
                            .foregroundColor(.black60)
                            .frame(width: 18, height: 18)

                        Text(application.category.name)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black60)
                            .lineLimit(1)
                    }
                }
                Spacer()
            }
        }
    }

    struct VersionSizeAPI: View {
        let application: Applications.Application

        var body: some View {
            HStack {
                Column(key: "Version", value: application.version)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                Divider()
                    .foregroundColor(.black4)
                Column(key: "Size", value: application.size)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                Divider()
                    .foregroundColor(.black4)
                Column(key: "API", value: application.api)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
            }
        }

        struct Column: View {
            let key: String
            let value: String

            var body: some View {
                VStack(spacing: 2) {
                    Text(key)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.black40)
                        .lineLimit(1)

                    Text(value)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
            }
        }
    }

    struct DeleteAppButton: View {
        var action: () -> Void

        var body: some View {
            Button {
                action()
            } label: {
                Image("AppDelete")
            }
        }
    }

    struct ShareAppButton: View {
        var action: () -> Void

        var body: some View {
            Button {
                action()
            } label: {
                Image("AppShare")
            }
        }
    }

    struct InstallAppButton: View {
        var action: () -> Void

        var body: some View {
            AppActionButton("INSTALL", color: .a1, action: action)
        }
    }

    struct UpdateAppButton: View {
        var action: () -> Void

        var body: some View {
            AppActionButton("UPDATE", color: .sGreenUpdate, action: action)
        }
    }

    struct InstalledAppButton: View {
        var body: some View {
            // swiftlint:disable trailing_closure
            AppActionButton("INSTALLED", color: .black20, action: {})
                .disabled(true)
        }
    }

    struct AppActionButton: View {
        let title: String
        let color: Color
        var action: () -> Void

        init(_ title: String, color: Color, action: @escaping () -> Void) {
            self.title = title
            self.color = color
            self.action = action
        }

        var body: some View {
            Button {
                action()
            } label: {
                HStack {
                    Text(title)
                        .foregroundColor(.white)
                        .font(.born2bSportyV2(size: 32))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(color)
                .cornerRadius(8)
            }
        }
    }

    struct Description: View {
        let description: String

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .font(.system(size: 16, weight: .bold))

                Text(description)
                    .font(.system(size: 14, weight: .regular))
            }
            .foregroundColor(.primary)
        }
    }

    struct Changelog: View {
        let changelog: String

        @State private var showMore = false

        private var shortChangelog: String {
            changelog.split(separator: "\n").prefix(5).joined(separator: "\n")
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 2) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Changelog")
                        .font(.system(size: 16, weight: .bold))

                    Markdown(showMore ? changelog : shortChangelog)
                        .markdownTextStyle {
                            FontSize(14)
                        }
                        .markdownBlockStyle(\.heading2) { label in
                            label
                                .markdownMargin(top: .rem(0), bottom: .rem(0.5))
                                .markdownTextStyle {
                                    FontWeight(.semibold)
                                    FontSize(.em(1))
                                }
                        }
                        .lineLimit(showMore ? nil : 4)
                }

                HStack {
                    Spacer()
                    Button {
                        showMore.toggle()
                    } label: {
                        Text(showMore ? "Less" : "More")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.black30)
                    }
                }
            }
            .foregroundColor(.primary)
        }
    }

    struct Developer: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("Developer")
                    .font(.system(size: 16, weight: .bold))

                HStack(spacing: 8) {
                    Image("GitHub")
                    Text("View on GitHub")
                        .font(.system(size: 14, weight: .medium))
                        .underline()
                }

                HStack(spacing: 8) {
                    Image("GitHub")
                    Text("Manifest")
                        .font(.system(size: 14, weight: .medium))
                        .underline()
                }

            }
            .foregroundColor(.primary)
        }
    }
}
