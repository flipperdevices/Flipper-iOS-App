import Foundation

public struct InfraredLayout: Decodable, Equatable {
    public let pages: [InfraredPageLayout]
}

public struct InfraredPageLayout: Decodable, Equatable {
    public let buttons: [InfraredButton]

    public init(buttons: [InfraredButton]) {
        self.buttons = buttons
    }
}
