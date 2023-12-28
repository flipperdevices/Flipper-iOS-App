import Core
import SwiftUI

extension AppView {
    struct Developer: View {
        let github: URL
        let manifest: URL

        @Environment(\.openURL) var openURL

        struct Title: View {
            var body: some View {
                Text("Developer")
                    .font(.system(size: 18, weight: .bold))
            }
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Title()

                UnderlinedURL(image: "GitHub", label: "Repository", url: github)

                UnderlinedURL(image: "GitHub", label: "Manifest", url: manifest)
            }
        }
    }
}
