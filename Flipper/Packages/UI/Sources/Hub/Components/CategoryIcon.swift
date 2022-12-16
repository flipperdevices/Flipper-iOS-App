import SwiftUI

struct CategoryIcon: View {
    let url: URL

    var body: some View {
        CacheAsyncImage(url: url) { phase in
            if let image = phase.image {
                image
                    .renderingMode(.template)
                    .interpolation(.none)
                    .resizable()
            }
        }
        .scaledToFit()
        .foregroundColor(.black)
    }
}

private struct CacheAsyncImage<Content>: View where Content: View {
    private let url: URL
    private let content: (AsyncImagePhase) -> Content

    init(
        url: URL,
        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
    ){
        self.url = url
        self.content = content
    }

    var body: some View{
        if let image = Cache[url] {
            content(.success(image))
        }else{
            AsyncImage(url: url, content: imageContent)
        }
    }

    func imageContent(for phase: AsyncImagePhase) -> some View {
        if case .success (let image) = phase {
            Cache[url] = image
        }
        return content(phase)
    }
}

private class Cache {
    static private var images: [URL: Image] = [:]

    static subscript(url: URL) -> Image? {
        get { Cache.images[url] }
        set { Cache.images[url] = newValue }
    }
}
