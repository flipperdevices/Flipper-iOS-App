import Core
import SwiftUI

struct AppsRowCard: View {
    @EnvironmentObject var model: Applications

    @State private var topApp: Applications.ApplicationInfo?
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

                    HubChevron()
                }

                if let topApp = topApp {
                    ApplicationDescription(item: topApp)
                } else if isError {
                    DefaultDescription()
                } else {
                    PlaceholderDescription()
                }
            }
        }
        .task { @MainActor in
            do {
                topApp = try await model.loadTopApp()
            } catch {
                isError = true
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
        let item: Applications.ApplicationInfo

        var category: Applications.Category? {
            model.category(for: item)
        }

        var body: some View {
            HStack(spacing: 8) {
                AppIcon(item.current.icon)
                    .frame(width: 42, height: 42)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.current.name)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    HStack(alignment: .bottom, spacing: 4) {
                        CategoryIcon(category?.icon)
                            .frame(width: 12, height: 12)

                        CategoryName(category?.name)
                            .font(.system(size: 10, weight: .medium))
                    }

                    Text(item.current.shortDescription)
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
                "Discover and install apps you'll like on your Flipper Zero"
            )
            .font(.system(size: 14, weight: .medium))
            .multilineTextAlignment(.leading)
            .foregroundColor(.black30)
        }
    }
}
