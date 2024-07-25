import Infrared

public struct InfraredButtonPosition {
    public let x: Double
    public let y: Double

    public let alignment: Alignment
    public let zIndex: Double

    public let containerWidth: Double
    public let containerHeight: Double

    public let contentWidth: Double
    public let contentHeight: Double

    public enum Alignment {
        case center
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
        case centerLeft
        case centerRight
    }

    init(_ button: Infrared.InfraredButton) {
        self.x = button.x
        self.y = button.y

        self.zIndex = button.zIndex
        self.alignment = button.alignment

        self.containerWidth = button.containerWidth
        self.containerHeight = button.containerHeight

        self.contentWidth = button.contentWidth
        self.contentHeight = button.contentHeight
    }
}

private extension InfraredButtonPosition.Alignment {
    init(_ alignment: Infrared.InfraredButtonPosition.Alignment?) {
        if let alignment {
            self = switch alignment {
            case .center: .center
            case .topLeft: .topLeft
            case .topRight: .topRight
            case .bottomLeft: .bottomLeft
            case .bottomRight: .bottomRight
            case .centerLeft: .centerLeft
            case .centerRight: .centerRight
            }
        }
        self = .center
    }
}

private extension Infrared.InfraredButton {
    var alignment: InfraredButtonPosition.Alignment {
        if let alignment = self.position.alignment {
            return switch alignment {
            case .center: .center
            case .topLeft: .topLeft
            case .topRight: .topRight
            case .bottomLeft: .bottomLeft
            case .bottomRight: .bottomRight
            case .centerLeft: .centerLeft
            case .centerRight: .centerRight
            }
        }
        return .center
    }

    var x: Double {
        Double(position.x)
    }

    var y: Double {
        Double(position.y)
    }

    var zIndex: Double {
        position.zIndex ?? 1.0
    }

    var containerWidth: Double {
        Double(position.containerWidth ?? containerDefaultWidth)
    }

    var containerHeight: Double {
        Double(position.containerHeight ?? containerDefaultHeight)
    }

    var contentWidth: Double {
        Double(position.contentWidth ?? contentDefaultWidth)
    }

    var contentHeight: Double {
        Double(position.contentHeight ?? contentDefaultHeight)
    }

    var containerDefaultWidth: Int {
        switch self.data {
        case .text, .icon, .base64Image, .unknown: 1
        case .navigation: 3
        case .volume, .channel: 1
        }
    }

    var containerDefaultHeight: Int {
        switch self.data {
        case .text, .icon, .base64Image, .unknown: 1
        case .navigation: 3
        case .volume, .channel: 3
        }
    }

    var contentDefaultWidth: Int {
        switch self.data {
        case .text, .icon, .base64Image, .unknown: 1
        case .navigation: 3
        case .volume, .channel: 1
        }
    }

    var contentDefaultHeight: Int {
        switch self.data {
        case .text, .icon, .base64Image, .unknown: 1
        case .navigation: 3
        case .volume, .channel: 3
        }
    }
}
