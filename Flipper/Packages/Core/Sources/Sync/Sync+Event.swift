import Peripheral

extension Sync {
    enum Event {
        case imported(Path)
        case exported(Path)
        case deleted(Path)
    }
}
