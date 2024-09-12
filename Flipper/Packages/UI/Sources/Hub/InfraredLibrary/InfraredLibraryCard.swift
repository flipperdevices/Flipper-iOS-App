import SwiftUI

struct InfraredLibraryCard: View {

    var body: some View {
        HubCard(
            icon: "infrared",
            title: "Infrared",
            image: "InfraredRemoteLibrary",
            subtitle: "Remotes Library",
            description: "Find remotes for your devices from a "
                        + "wide range of brands and models"
        ) {
            Badge()
        }
    }

    struct Badge: View {
        @Environment(\.colorScheme) var colorScheme

        private var color: Color {
            switch colorScheme {
            case .light: return .black40
            default: return .black30
            }
        }

        var body: some View {
            Text("Beta")
                .font(.system(size: 12))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .foregroundColor(color)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(color, lineWidth: 1)
                )
                .padding(.trailing, 4)
        }
    }
}
