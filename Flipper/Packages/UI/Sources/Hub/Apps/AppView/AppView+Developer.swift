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

        struct LinkLabel: View {
            let text: String

            init(_ text: String) {
                self.text = text
            }

            var body: some View {
                Text(text)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .underline()
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
                        LinkLabel("View on GitHub")
                    }
                }

                HStack(spacing: 8) {
                    Image("GitHub")
                    Button {
                        openURL(manifest)
                    } label: {
                        LinkLabel("Manifest")
                    }
                }
            }
        }
    }
}
