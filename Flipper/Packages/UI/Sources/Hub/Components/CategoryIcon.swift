import Core
import SwiftUI
import Foundation
import SVGKit

struct CategoryIcon: View {
    @Environment(\.colorScheme) var colorScheme

    let url: URL?
    let fixme: Bool

    init(_ url: URL?, fixme: Bool = false) {
        self.url = url
        self.fixme = fixme
    }

    private var color: Color {
        switch colorScheme {
        case .dark: return .black40
        default: return .black60
        }
    }

    var body: some View {
        Group {
            if let url = url {
                RemoteImage(url: url)
            } else {
                Image("UnknownCategory")
            }
        }
        .foregroundColor(fixme ? .primary : color)
    }

    struct RemoteImage: View {
        let url: URL

        static var cache: [URL: SVGKImage] = [:]

        @State var svgkImage: SVGKImage?

        var body: some View {
            ZStack {
                Image(uiImage: svgkImage?.uiImage ?? .init())
                    .renderingMode(.template)
                    .interpolation(.none)
                    .resizable()
                    .opacity(svgkImage == nil ? 0 : 1)

                AnimatedPlaceholder()
                    .opacity(svgkImage == nil ? 1 : 0)
            }
            .task {
                do {
                    if let svgkImage = Self.cache[url] {
                        self.svgkImage = svgkImage
                    } else {
                        let (data, _) = try await URLSession
                            .shared
                            .data(from: url)
                        let svgkImage = SVGKImage(data: data)
                        Self.cache[url] = svgkImage
                        self.svgkImage = svgkImage
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
}
