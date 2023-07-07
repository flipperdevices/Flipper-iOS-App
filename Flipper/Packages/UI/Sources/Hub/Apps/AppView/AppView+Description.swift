import Core
import SwiftUI

import MarkdownUI

extension AppView {
    struct Description: View {
        let description: String

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .font(.system(size: 18, weight: .bold))

                Markdown(description)
                    .customMarkdownStyle()
            }
            .foregroundColor(.primary)
        }
    }
}
