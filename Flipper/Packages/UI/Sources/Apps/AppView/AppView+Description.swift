import Core
import SwiftUI

import MarkdownUI

extension AppView {
    struct Description: View {
        let description: String

        struct Title: View {
            var body: some View {
                Text("Description")
                    .font(.system(size: 18, weight: .bold))
            }
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Title()

                Markdown(description)
                    .customMarkdownStyle()
            }
        }
    }
}
