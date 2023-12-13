import Catalog

import SwiftUI

struct AppIcon: View {
    let source: ImageSource

    init(_ source: ImageSource) {
        self.source = source
    }

    var body: some View {
        Group {
            Group {
                switch source {
                case .url(let url):
                    URLImage(url: url)
                case .data(let data):
                    DataImage(data: data)
                }
            }
            .foregroundColor(.primary)
            .scaledToFit()
            .padding(5)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.black16Black60)
        }
    }

    struct URLImage: View {
        let url: URL

        var body: some View {
            CachedAsyncImage(url: url) { image in
                image
                    .renderingMode(.template)
                    .interpolation(.none)
                    .resizable()
            } placeholder: {
                AnimatedPlaceholder()
                    .aspectRatio(1, contentMode: .fit)
            }
        }
    }

    struct DataImage: View {
        let data: Data

        var body: some View {
            if let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .renderingMode(.template)
                    .interpolation(.none)
                    .resizable()
            } else {
                AnimatedPlaceholder()
            }
        }
    }
}
