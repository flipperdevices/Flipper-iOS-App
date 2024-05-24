import Core
import SwiftUI

public struct CachedAsyncImage<Content, PlaceholderContent, ErrorContent>: View
where Content: View, PlaceholderContent: View, ErrorContent: View {

    public typealias ContentImage = ((UIImage) -> Content)
    public typealias ContentPlaceholder = (() -> PlaceholderContent)
    public typealias ContentError = (() -> ErrorContent)

    private let url: URL
    private let contentImage: ContentImage
    private let placeholder: ContentPlaceholder
    private let contentError: ContentError?

    enum ImageState {
        case ready(UIImage)
        case inProgress
        case error
    }

    @State private var state: ImageState = .inProgress

    public init(
        url: URL,
        @ViewBuilder content: @escaping ContentImage,
        @ViewBuilder placeholder: @escaping ContentPlaceholder
    )  where ErrorContent == Never {
        self.url = url
        self.contentImage = content
        self.placeholder = placeholder
        self.contentError = nil
    }

    public init(
        url: URL,
        @ViewBuilder content: @escaping ContentImage,
        @ViewBuilder placeholder: @escaping ContentPlaceholder,
        @ViewBuilder error: @escaping ContentError
    ) {
        self.url = url
        self.contentImage = content
        self.placeholder = placeholder
        self.contentError = error
    }

    public var body: some View {
        Group {
            switch state {
            case .inProgress:
                placeholder()
            case .error:
                if let errorView = contentError?() {
                    errorView
                } else {
                    placeholder()
                }
            case .ready(let image):
                contentImage(image)
            }
        }
        .task { await getImage() }
    }

    private func getImage() async {
        do {
            let data = try await CachedNetworkLoader.shared.get(url)

            guard let uiImage = UIImage(data: data) else {
                self.state = .error
                return
            }

            self.state = .ready(uiImage)
        } catch {
            self.state = .error
        }
    }
}
