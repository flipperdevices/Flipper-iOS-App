import Core
import SwiftUI

struct AppList: View {
    @EnvironmentObject var model: Applications
    let applications: [Applications.Application]

    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<applications.count, id: \.self) { index in
                let application = applications[index]

                NavigationLink {
                    AppView(application: application)
                        .environmentObject(model)
                } label: {
                    AppRow(application: application)
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

struct AppRow: View {
    @EnvironmentObject var model: Applications
    let application: Applications.Application

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                IconNameCategory(application: application)

                Spacer()

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
            .padding(.horizontal, 14)

            AppScreens(application: application)
                .frame(height: 84)

            Text(application.shortDescription)
                .font(.system(size: 12, weight: .medium))
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 14)
                .lineLimit(2)
        }
    }

    struct IconNameCategory: View {
        let application: Applications.Application

        var body: some View {
            HStack(spacing: 8) {
                AppIcon(url: application.icon)
                    .frame(width: 42, height: 42)

                VStack(alignment: .leading, spacing: 2) {
                    Text(application.name)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    HStack(spacing: 4) {
                        CategoryIcon(image: application.category.icon)
                            .foregroundColor(.black40)
                            .frame(width: 14, height: 14)

                        Text(application.category.name)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.black40)
                            .lineLimit(1)
                    }
                }
            }
        }
    }

    struct UpdateAllAppButton: View {
        let action: () -> Void

        var body: some View {
            Button {
                action()
            } label: {
                HStack {
                    Text("UPDATE ALL")
                        .foregroundColor(.white)
                        .font(.born2bSportyV2(size: 18))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(Color.sGreenUpdate)
                .cornerRadius(8)
            }
        }
    }

    struct InstallAppButton: View {
        var action: () -> Void

        var body: some View {
            AppActionButton(title: "INSTALL", color: .a1, action: action)
        }
    }

    struct UpdateAppButton: View {
        var action: () -> Void

        var body: some View {
            AppActionButton(title: "UPDATE", color: .sGreenUpdate, action: action)
        }
    }

    struct InstalledAppButton: View {
        var body: some View {
            // swiftlint:disable trailing_closure
            AppActionButton(title: "INSTALLED", color: .black20, action: {})
                .disabled(true)
        }
    }

    struct AppActionButton: View {
        let title: String
        let color: Color
        var action: () -> Void

        var body: some View {
            Button {
                action()
            } label: {
                HStack {
                    Text(title)
                        .foregroundColor(.white)
                        .font(.born2bSportyV2(size: 18))
                }
                .frame(width: 116, height: 32)
                .background(color)
                .cornerRadius(6)
            }
        }
    }

}
