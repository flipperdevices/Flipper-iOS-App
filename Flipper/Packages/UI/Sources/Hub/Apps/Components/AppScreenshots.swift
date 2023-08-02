import Core
import SwiftUI

struct AppScreens: View {
    let screenshots: [URL]

    init(_ screenshots: [URL]) {
        self.screenshots = screenshots
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(screenshots) { screenshot in
                    Screenshot(url: screenshot)
                }
            }
            .padding(.horizontal, 14)
        }
    }

    struct Screenshot: View {
        let url: URL
        var cornerRadius: Double { 8 }

        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.a1)
                    .padding(1)

                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(.black, lineWidth: 1)
                    .padding(1)

                AsyncImage(url: url) { image in
                    image
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    AnimatedPlaceholder()
                        .aspectRatio(2, contentMode: .fit)
                }
                .padding(cornerRadius / 2)
            }
        }
    }
}
