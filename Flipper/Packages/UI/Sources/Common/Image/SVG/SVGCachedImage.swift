import Core
import SwiftUI

public struct SVGCachedImage<PlaceholderContent, ErrorContent>: View
where PlaceholderContent: View, ErrorContent: View {

    public typealias ContentPlaceholder = (() -> PlaceholderContent)
    public typealias ContentError = (() -> ErrorContent)

    private let url: URL?
    private let placeholder: ContentPlaceholder
    private let contentError: ContentError?

    enum ImageState {
        case ready(data: SVGData)
        case inProgress
        case error
    }

    @State private var state: ImageState = .inProgress

    public init(
        url: URL?,
        @ViewBuilder placeholder: @escaping ContentPlaceholder
    )  where ErrorContent == Never {
        self.url = url
        self.placeholder = placeholder
        self.contentError = nil
    }

    public init(
        url: URL?,
        @ViewBuilder placeholder: @escaping ContentPlaceholder,
        @ViewBuilder error: @escaping ContentError
    ) {
        self.url = url
        self.placeholder = placeholder
        self.contentError = error
    }

    public var body: some View {
        GeometryReader { proxy in
            switch state {
            case .inProgress:
                placeholder()
            case .error:
                if let errorView = contentError?() {
                    errorView
                } else {
                    placeholder()
                }
            case .ready(let data):
                let scaleX = proxy.size.width / data.width
                let scaleY = proxy.size.height / data.height

                data.path
                    .scaleEffect(
                        x: scaleX,
                        y: scaleY,
                        anchor: .topLeading
                    )
            }
        }
        .task { await getSVGImage() }
    }

    private func getSVGImage() async {
        do {
            guard let url = url else {
                self.state = .error
                return
            }

            let svgData = try await SVGCachedPathLoader.shared.get(url)
            self.state = .ready(data: svgData)
        } catch {
            self.state = .error
        }
    }
}
