import Inject

extension Archive {
    func synchronize() async {
        guard !isSyncronizing else { return }
        do {
            try await archiveSync.run()
        } catch {
            logger.critical("syncronization error: \(error)")
        }
    }

    func onSyncEvent(_ event: ArchiveSync.Event) {
        Task {
            switch event {
            case .syncing(let path):
                if let index = items.firstIndex(where: { $0.path == path }) {
                    items[index].status = .synchronizing
                }
            case .imported(let path):
                let content = try await mobileArchive.read(path)
                var item = try ArchiveItem(path: path, content: content)
                item.status = .synchronized
                items.removeAll { $0.path == path }
                items.append(item)
            case .exported(let path):
                if let index = items.firstIndex(where: { $0.path == path }) {
                    items[index].status = .synchronized
                }
            case .deleted(let path):
                if let index = items.firstIndex(where: { $0.path == path }) {
                    try await backup(items[index])
                    items.removeAll { $0.path == path }
                }
            }
        }
    }
}
