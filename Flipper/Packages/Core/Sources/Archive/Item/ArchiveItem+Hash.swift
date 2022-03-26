import Bluetooth

extension ArchiveItem {
    var hash: Hash {
        .init(content.md5)
    }
}
