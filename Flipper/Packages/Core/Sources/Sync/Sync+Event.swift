import Peripheral

extension Sync {
    enum Event {
        case syncing(Path)
        case imported(Path)
        case exported(Path)
        case deleted(Path)
    }
}
