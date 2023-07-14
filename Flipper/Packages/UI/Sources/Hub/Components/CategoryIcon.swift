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
