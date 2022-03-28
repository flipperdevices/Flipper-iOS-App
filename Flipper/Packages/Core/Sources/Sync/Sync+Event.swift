import Peripheral

extension ArchiveSync {
    enum Event {
        case syncing(Path)
        case imported(Path)
        case exported(Path)
        case deleted(Path)
    }
}
