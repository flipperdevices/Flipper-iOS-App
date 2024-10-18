import Infrared
import Foundation

public struct InfraredLayout: Equatable, Codable, Hashable {
    public let pages: [InfraredPageLayout]

    init(_ layout: Infrared.InfraredLayout) {
        self.pages = layout.pages.map(InfraredPageLayout.init)
    }

    init(pages: [InfraredPageLayout]) {
        self.pages = pages
    }
}

public struct InfraredPageLayout: Equatable, Codable, Hashable {
    public let buttons: [InfraredButton]

    init(_ page: Infrared.InfraredPageLayout) {
        self.buttons = page.buttons.map(InfraredButton.init)
    }

    init(buttons: [InfraredButton]) {
        self.buttons = buttons
    }
}

public extension InfraredLayout {
    var data: Data? {
        content?.data(using: .utf8)
    }

    var content: String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys // Save order

        guard
            let layout = try? encoder.encode(self),
            let content = String(data: layout, encoding: .utf8)
        else { return nil }

        return content
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\t", with: "")
            .replacingOccurrences(of: "\r", with: "")
    }
}

public extension InfraredLayout {
    static let progressMock: InfraredLayout = .init(pages: [.progressMock])
}

public extension InfraredPageLayout {
    static let progressMock: InfraredPageLayout = .init(buttons: [
        .init(position: .init(x: 0, y: 0), data: .unknown),
        .init(position: .init(x: 0, y: 1), data: .unknown),
        .init(position: .init(x: 0, y: 2), data: .unknown),
        .init(position: .init(x: 0, y: 3), data: .unknown),
        .init(position: .init(x: 0, y: 4), data: .unknown),
        .init(position: .init(x: 0, y: 5), data: .unknown),
        .init(position: .init(x: 0, y: 6), data: .unknown),
        .init(position: .init(x: 0, y: 7), data: .unknown),
        .init(position: .init(x: 0, y: 8), data: .unknown),
        .init(position: .init(x: 0, y: 9), data: .unknown),
        .init(position: .init(x: 0, y: 10), data: .unknown),
        .init(position: .init(x: 1, y: 0), data: .unknown),
        .init(position: .init(x: 1, y: 1), data: .unknown),
        .init(position: .init(x: 1, y: 2), data: .unknown),
        .init(position: .init(x: 1, y: 3), data: .unknown),
        .init(position: .init(x: 1, y: 4), data: .unknown),
        .init(position: .init(x: 1, y: 5), data: .unknown),
        .init(position: .init(x: 1, y: 6), data: .unknown),
        .init(position: .init(x: 1, y: 7), data: .unknown),
        .init(position: .init(x: 1, y: 8), data: .unknown),
        .init(position: .init(x: 1, y: 9), data: .unknown),
        .init(position: .init(x: 1, y: 10), data: .unknown),
        .init(position: .init(x: 2, y: 0), data: .unknown),
        .init(position: .init(x: 2, y: 1), data: .unknown),
        .init(position: .init(x: 2, y: 2), data: .unknown),
        .init(position: .init(x: 2, y: 3), data: .unknown),
        .init(position: .init(x: 2, y: 4), data: .unknown),
        .init(position: .init(x: 2, y: 5), data: .unknown),
        .init(position: .init(x: 2, y: 6), data: .unknown),
        .init(position: .init(x: 2, y: 7), data: .unknown),
        .init(position: .init(x: 2, y: 8), data: .unknown),
        .init(position: .init(x: 2, y: 9), data: .unknown),
        .init(position: .init(x: 2, y: 10), data: .unknown),
        .init(position: .init(x: 3, y: 0), data: .unknown),
        .init(position: .init(x: 3, y: 1), data: .unknown),
        .init(position: .init(x: 3, y: 2), data: .unknown),
        .init(position: .init(x: 3, y: 3), data: .unknown),
        .init(position: .init(x: 3, y: 4), data: .unknown),
        .init(position: .init(x: 3, y: 5), data: .unknown),
        .init(position: .init(x: 3, y: 6), data: .unknown),
        .init(position: .init(x: 3, y: 7), data: .unknown),
        .init(position: .init(x: 3, y: 8), data: .unknown),
        .init(position: .init(x: 3, y: 9), data: .unknown),
        .init(position: .init(x: 3, y: 10), data: .unknown),
        .init(position: .init(x: 4, y: 0), data: .unknown),
        .init(position: .init(x: 4, y: 1), data: .unknown),
        .init(position: .init(x: 4, y: 2), data: .unknown),
        .init(position: .init(x: 4, y: 3), data: .unknown),
        .init(position: .init(x: 4, y: 4), data: .unknown),
        .init(position: .init(x: 4, y: 5), data: .unknown),
        .init(position: .init(x: 4, y: 6), data: .unknown),
        .init(position: .init(x: 4, y: 7), data: .unknown),
        .init(position: .init(x: 4, y: 8), data: .unknown),
        .init(position: .init(x: 4, y: 9), data: .unknown),
        .init(position: .init(x: 4, y: 10), data: .unknown)
    ])
}
