import Infrared

public enum InfraredButtonType {
    case text(InfraredTextButton)
    case icon(InfraredIconButton)
    case base64Image(InfraredBase64ImageButton)
    case navigation(InfraredNavigationButton)
    case channel(InfraredChannelButton)
    case volume(InfraredVolumeButton)
    case unknown

    init(_ type: Infrared.InfraredButtonData) {
        switch type {
        case .text(let data):
            self = .text(InfraredTextButton(data))
        case .icon(let data):
            self = .icon(InfraredIconButton(data))
        case .base64Image(let data):
            self = .base64Image(InfraredBase64ImageButton(data))
        case .navigation(let data):
            self = .navigation(InfraredNavigationButton(data))
        case .volume(let data):
            self = .volume(InfraredVolumeButton(data))
        case .channel(let data):
            self = .channel(InfraredChannelButton(data))
        case .unknown:
            self = .unknown
        }
    }
}

public struct InfraredTextButton {
    public let keyId: InfraredKeyID
    public let text: String

    init(_ data: Infrared.TextButtonData) {
        self.keyId = .init(data.keyId)
        self.text = data.text
    }
}

public struct InfraredIconButton {
    public let keyId: InfraredKeyID
    public let type: `Type`

    public enum `Type` {
        case back
        case home
        case info
        case more
        case mute
        case power
        case cool
        case heat
    }

    init(_ data: Infrared.IconButtonData) {
        self.keyId = .init(data.keyId)

        self.type = switch data.icon {
        case .back: .back
        case .home: .home
        case .info: .info
        case .more: .more
        case .mute: .mute
        case .cool: .cool
        case .heat: .heat
        case .power:  .power
        }
    }
}

public struct InfraredBase64ImageButton {
    public let keyId: InfraredKeyID
    public let image: String

    init(_ data: Infrared.Base64ImageButtonData) {
        self.keyId = .init(data.keyId)
        self.image = data
            .pngBase64
            .replacing("data:image/png;base64,", with: "")
    }
}

public struct InfraredNavigationButton {
    public let upKeyId: InfraredKeyID
    public let leftKeyId: InfraredKeyID
    public let downKeyId: InfraredKeyID
    public let rightKeyId: InfraredKeyID
    public let okKeyId: InfraredKeyID

    init(_ data: Infrared.NavigationButtonData) {
        self.upKeyId = .init(data.upKeyId)
        self.leftKeyId = .init(data.leftKeyId)
        self.downKeyId = .init(data.downKeyId)
        self.rightKeyId = .init(data.rightKeyId)
        self.okKeyId = .init(data.okKeyId)
    }
}

public struct InfraredVolumeButton {
    public let addKeyId: InfraredKeyID
    public let reduceKeyId: InfraredKeyID

    init(_ data: Infrared.VolumeButtonData) {
        self.addKeyId = .init(data.addKeyId)
        self.reduceKeyId = .init(data.reduceKeyId)
    }
}

public struct InfraredChannelButton {
    public let addKeyId: InfraredKeyID
    public let reduceKeyId: InfraredKeyID

    init(_ data: Infrared.ChannelButtonData) {
        self.addKeyId = .init(data.addKeyId)
        self.reduceKeyId = .init(data.reduceKeyId)
    }
}
