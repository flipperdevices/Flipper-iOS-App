import SVGKit
import SwiftUI
import Foundation

extension Image {
    init(svg data: Data) {
        self.init(uiImage: SVGKImage(data: data).uiImage)
    }

    init(base64EncodedSVG: String) {
        self.init(svg: .init(base64Encoded: base64EncodedSVG) ?? .init())
    }
}
