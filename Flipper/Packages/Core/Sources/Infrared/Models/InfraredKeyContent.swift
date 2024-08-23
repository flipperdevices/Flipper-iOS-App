import Infrared

public struct InfraredKeyContent {
    public let properties: [ArchiveItem.Property]

    init(_ keyContent: Infrared.InfraredKeyContent) {
        let properties = [ArchiveItem.Property](
            content: keyContent.content
        )

        self.properties = properties ?? []
    }
}
