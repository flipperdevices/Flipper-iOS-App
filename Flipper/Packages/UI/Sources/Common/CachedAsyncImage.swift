import SwiftUI

public struct CachedAsyncImage<Content, PlaceholderContent>: View
where Content: View, PlaceholderContent: View {
    public typealias ContentPhase = ((AsyncImagePhase) -> Content)
    public typealias ContentImage = ((Image) -> Content)
    public typealias Placeholder = (() -> PlaceholderContent)

    public enum Kind {
        case byPhase(ContentPhase)
        case byImage(ContentImage, Placeholder)
    }

    @State private var countRetry = 0
    @State var id = UUID()

    private let url: URL?
    private let scale: CGFloat
    private let kind: Kind
    private let transaction: Transaction

    var canRepeatRetry: Bool {
        countRetry < 3
    }

    public init(
        url: URL?,
        scale: CGFloat = 1.0,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping ContentPhase
    ) {
        self.url = url
        self.scale = scale
        self.transaction = transaction
        self.kind = .byPhase(content)
    }

    public init(
        url: URL?,
        scale: CGFloat = 1,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping ContentImage,
        @ViewBuilder placeholder: @escaping Placeholder
    ) {
        self.url = url
        self.scale = scale
        self.transaction = transaction
        self.kind = .byImage(content, placeholder)
    }

    public var body: some View {
        if let cached = ImageInMemoryCache[url] {
            switch kind {
            case .byImage(let contentImage, _): contentImage(cached)
            case .byPhase(let contentPhase): contentPhase(.success(cached))
            }
        } else {
            switch kind {
            case .byImage(let contentImage, let placeholder):
                AsyncImage(
                    url: url,
                    scale: scale,
                    transaction: transaction,
                    content: { phase in
                        switch phase {
                        case .success(let image):
                            cacheAndRender(
                                image: image,
                                contentImage: contentImage
                            )
                        case .empty:
                            placeholder()
                        case .failure(let error):
                            placeholder()
                                .onAppear { onError(error) }
                        @unknown default:
                            placeholder()
                        }
                    }
                )
                .id(id)
            case .byPhase(let contentPhase):
                AsyncImage(
                    url: url,
                    scale: scale,
                    transaction: transaction,
                    content: {
                        cacheAndRender(phase: $0, contentPhase: contentPhase)
                    }
                )
            }
        }
    }
}

// MARK: Private methods

private extension CachedAsyncImage {
    func cacheAndRender(
        image: Image,
        contentImage: ContentImage
    ) -> some View {
        ImageInMemoryCache[url] = image
        return contentImage(image)
    }

    func cacheAndRender(
        phase: AsyncImagePhase,
        contentPhase: ContentPhase
    ) -> some View {
        if case .success(let image) = phase {
            ImageInMemoryCache[url] = image
        }
        return contentPhase(phase)
    }

    func onError(_ error: Swift.Error) {
        guard countRetry < 3 else { return }

        self.id = UUID()
        self.countRetry += 1
    }
}

// MARK: Private cache for CachedAsyncImage

private class ImageInMemoryCache {
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
