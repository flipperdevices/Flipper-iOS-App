import SwiftUI

public struct CachedAsyncImage<Content, PlaceholderContent>: View where Content: View, PlaceholderContent: View {
    private let url: URL?
    private let scale: CGFloat
    private let transaction: Transaction?
    private let contentPhase: ((AsyncImagePhase) -> Content)?
    private let contentImage: ((Image) -> Content)?
    private let placeholder: (() -> PlaceholderContent)?

    public init(
        url: URL?,
        scale: CGFloat = 1.0,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
    ) {
        self.url = url
        self.scale = scale
        self.transaction = transaction
        self.contentPhase = content
        self.contentImage = nil
        self.placeholder = nil
    }

    public init(
        url: URL?,
        scale: CGFloat = 1,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> PlaceholderContent
    ) {
        self.url = url
        self.scale = scale
        self.contentImage = content
        self.placeholder = placeholder
        self.contentPhase = nil
        self.transaction = nil
    }
    
    public var body: some View {
        if let cached = ImageInMemoryCache[url] {
            if contentPhase != nil {
                contentPhase?(.success(cached))
            } else if contentImage != nil {
                contentImage?(cached)
            }
        } else {
            if contentPhase != nil {
                AsyncImage(
                    url: url,
                    scale: scale,
                    transaction: transaction ?? Transaction(),
                    content: { cacheAndRender(phase: $0) }
                )
            } else if contentImage != nil, let placeholder {
                AsyncImage(
                    url: url,
                    scale: scale,
                    content: { cacheAndRender(image: $0) },
                    placeholder: placeholder
                )
            }
        }
    }
}

// MARK: Private methods

private extension CachedAsyncImage {
    
    func cacheAndRender(image: Image) -> some View {
        ImageInMemoryCache[url] = image
        return contentImage?(image)
    }

    func cacheAndRender(phase: AsyncImagePhase) -> some View {
        if case .success (let image) = phase {
            ImageInMemoryCache[url] = image
        }
        return contentPhase?(phase)
    }
}

// MARK: Private cache for CachedAsyncImage

fileprivate class ImageInMemoryCache {
    
    static private var cache: [URL: Image] = [:]
    
    static subscript(url: URL?) -> Image? {
        get {
            guard let url else { return nil }
            return ImageInMemoryCache.cache[url]
        }
        set {
            guard let url else { return }
            ImageInMemoryCache.cache[url] = newValue
        }
    }
}
