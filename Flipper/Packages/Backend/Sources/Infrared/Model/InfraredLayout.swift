import Foundation

public struct InfraredLayout: Codable, Equatable {
    public let pages: [InfraredPageLayout]
}

public struct InfraredPageLayout: Codable, Equatable {
    public let buttons: [InfraredButton]

    public init(buttons: [InfraredButton]) {
        self.buttons = buttons
    }
}
