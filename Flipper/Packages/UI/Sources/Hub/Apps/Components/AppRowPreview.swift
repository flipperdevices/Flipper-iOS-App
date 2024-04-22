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
                    .frame(width: 48, height: 48)

                VStack(alignment: .leading, spacing: 4) {
                    AnimatedPlaceholder()
                        .frame(maxWidth: .infinity)
                        .frame(width: 102, height: 18)

                    AnimatedPlaceholder()
                        .frame(width: 42, height: 14)
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

                if isInstalled {
                    AnimatedPlaceholder()
                        .frame(width: 34, height: 34)
                }
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
