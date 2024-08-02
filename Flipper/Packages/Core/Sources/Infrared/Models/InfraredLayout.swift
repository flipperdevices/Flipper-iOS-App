import Infrared

public struct InfraredLayout {
    public let pages: [InfraredPageLayout]

    init(_ layout: Infrared.InfraredLayout) {
        self.pages = layout.pages.map(InfraredPageLayout.init)
    }
}

public struct InfraredPageLayout {
    public let buttons: [InfraredButton]

    init(_ page: Infrared.InfraredPageLayout) {
        self.buttons = page.buttons.map(InfraredButton.init)
    }
}
