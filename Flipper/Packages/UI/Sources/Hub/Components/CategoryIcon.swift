import Core
import SwiftUI
import Foundation
import SVGKit

struct CategoryIcon: View {
    let image: Applications.Category.ImageSource

    var body: some View {
        Group {
            switch image {
            case .assets(let name): Image(name)
            case .remote(let url): RemoteImage(url: url)
            }
        }
    }

    struct RemoteImage: View {
        let url: URL

        @State var svgData: Data?

        var body: some View {
            Group {
                if let svgData = svgData {
                    Image(uiImage: SVGKImage(data: svgData).uiImage)
                        .renderingMode(.template)
                        .interpolation(.none)
                        .resizable()
                } else {
                    AnimatedPlaceholder()
                }
            }
            .task {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    self.svgData = data
                } catch {
                    print(error)
                }
            }
        }
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
