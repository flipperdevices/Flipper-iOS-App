import Core
import SwiftUI

struct AppsRowCard: View {
    @EnvironmentObject var model: Applications

    @State private var topApp: Application?
    @State private var isError: Bool = false

    var body: some View {
        HubRowCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    HStack(spacing: 12) {
                        Image("Apps")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 30, height: 30)
                            .foregroundColor(.primary)

                        Text("Apps")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                    }

                    Spacer(minLength: 8)

                    HStack(spacing: 2) {
                        if model.outdatedCount > 0 {
                            UpdatesAvailable()
                        }
                        HubChevron()
                    }
                }

                if let topApp {
                    ApplicationDescription(application: topApp)
                } else if isError {
                    DefaultDescription()
                } else {
                    PlaceholderDescription()
                }
            }
        }
        .task {
            do {
                topApp = try await model.loadTopApp()
            } catch {
                isError = true
            }
        }
    }

    struct UpdatesAvailable: View {
        var body: some View {
            Text("Updates Available")
                .font(.system(size: 10, weight: .bold))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.sGreenUpdate)
                }
        }
    }

    struct PlaceholderDescription: View {
        var body: some View {
            HStack(spacing: 8) {
                AnimatedPlaceholder()
                    .frame(width: 42, height: 42)

                VStack(alignment: .leading, spacing: 2) {
                    AnimatedPlaceholder()
                        .frame(width: 84, height: 12)

                    AnimatedPlaceholder()
                        .frame(width: 36, height: 12)

                    AnimatedPlaceholder()
                        .frame(maxWidth: .infinity)
                        .frame(height: 12)
                }
            }
        }
    }

    struct ApplicationDescription: View {
        @EnvironmentObject var model: Applications
        let application: Application

        var body: some View {
            HStack(spacing: 8) {
                AppIcon(application.current.icon)
                    .frame(width: 42, height: 42)

                VStack(alignment: .leading, spacing: 2) {
                    Text(application.current.name)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    HStack(alignment: .bottom, spacing: 4) {
                        CategoryIcon(application.category.icon.url)
                            .frame(width: 12, height: 12)

                        CategoryName(application.category.name)
                            .font(.system(size: 10, weight: .medium))
                    }

                    Text(application.current.shortDescription)
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
            }
        }
    }

    struct DefaultDescription: View {
        var body: some View {
            Text(
                "Discover and install apps you like on your Flipper Zero"
            )
            .font(.system(size: 14, weight: .medium))
            .multilineTextAlignment(.leading)
            .foregroundColor(.black30)
        }
    }
}
