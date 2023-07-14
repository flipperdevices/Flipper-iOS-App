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

                HStack(spacing: 8) {
                    Image("GitHub")
                    Button {
                        openURL(github)
                    } label: {
                        Text("View on GitHub")
                            .font(.system(size: 14, weight: .medium))
                            .underline()
                    }
                }

                HStack(spacing: 8) {
                    Image("GitHub")
                    Button {
                        openURL(manifest)
                    } label: {
                        Text("Manifest")
                            .font(.system(size: 14, weight: .medium))
                            .underline()
                    }
                }

            }
        }
    }
}
