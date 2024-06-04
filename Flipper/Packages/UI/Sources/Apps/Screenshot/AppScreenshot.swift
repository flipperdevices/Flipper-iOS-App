import SwiftUI

struct AppScreenshot: View {
    let url: URL
    let onComplete: (UIImage) -> Void

    init(
        url: URL,
        onComplete: @escaping (UIImage) -> Void = { _ in }
    ) {
        self.url = url
        self.onComplete = onComplete
    }

    var cornerRadius: Double { 8 }

    var body: some View {
        CachedAsyncImage(url: url) { image in
            Image(uiImage: image)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .padding(cornerRadius / 2)
                .onAppear { onComplete(image) }
        } placeholder: {
            AnimatedPlaceholder()
                .aspectRatio(2, contentMode: .fit)
        }
        .padding(cornerRadius / 2 )
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.a1)
                    .padding(1)

                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(.black, lineWidth: 1)
                    .padding(1)
            }
        )
    }
}
