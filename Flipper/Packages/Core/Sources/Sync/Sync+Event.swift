extension Sync {
    enum Event {
        case imported(ArchiveItem.ID)
        case exported(ArchiveItem.ID)
        case deleted(ArchiveItem.ID)
    }
}
