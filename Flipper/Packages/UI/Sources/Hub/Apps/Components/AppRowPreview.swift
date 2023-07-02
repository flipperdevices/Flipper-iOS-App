import Core
import SwiftUI

struct AppRowPreview: View {
    let isInstalled: Bool

    init(isInstalled: Bool = false) {
        self.isInstalled = isInstalled
    }

    struct IconNameCategoryPreview: View {
        var body: some View {
            HStack(spacing: 8) {
                AnimatedPlaceholder()
                    .frame(width: 42, height: 42)

                VStack(alignment: .leading, spacing: 2) {
                    AnimatedPlaceholder()
                        .frame(maxWidth: .infinity)
                        .frame(height: 17)

                    AnimatedPlaceholder()
                        .frame(width: 62, height: 14)
                }
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                IconNameCategoryPreview()

                Spacer()

                AnimatedPlaceholder()
                    .frame(width: 92, height: 34)
            }
            .padding(.horizontal, 14)

            if !isInstalled {
                AnimatedPlaceholder()
                    .frame(width: 170, height: 84)
                    .padding(.horizontal, 14)

                AnimatedPlaceholder()
                    .frame(maxWidth: .infinity)
                    .frame(height: 17)
                    .padding(.horizontal, 14)
            }
        }
    }
}
