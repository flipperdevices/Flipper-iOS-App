import Core
import SwiftUI

struct AppsRowCard: View {
    @EnvironmentObject var model: Applications

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

                if let item = model.topApp {
                    ApplicationDescription(item: item)
                } else if case .loading = model.state {
                    PlaceholderDescription()
                } else {
                    DefaultDescription()
                }
            }
        }
        .task {
            Task {
                try await model.loadTopApp()
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
        let item: Applications.Application

        var body: some View {
            HStack(spacing: 8) {
                AppIcon(url: item.icon)
                    .frame(width: 42, height: 42)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    HStack(alignment: .bottom, spacing: 4) {
                        CategoryIcon(image: item.category.icon)
                            .foregroundColor(.black60)
                            .frame(width: 12, height: 12)

                        Text(item.category.name)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.black60)
                            .lineLimit(1)
                    }

                    Text(item.shortDescription)
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
                "Discover and install apps you'll like on your Fipper Zero"
            )
            .font(.system(size: 14, weight: .medium))
            .multilineTextAlignment(.leading)
            .foregroundColor(.black30)
        }
    }
}
