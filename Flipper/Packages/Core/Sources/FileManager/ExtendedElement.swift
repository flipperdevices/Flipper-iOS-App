import Peripheral

public struct ExtendedElement: Equatable, Identifiable {
    public var id: String { path.string }

    public let path: Path
    public let type: Element

    public var name: String {
        type.name
    }
}

extension ExtendedElement {
    init(element: Element, relativeTo path: Path) {
        self.path = path.appending(element.name)
        self.type = element
    }
}
