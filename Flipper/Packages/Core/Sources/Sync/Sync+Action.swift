import Peripheral

extension ArchiveSync {
    enum Action {
        case update(Target)
        case delete(Target)
        case conflict

        enum Target {
            case mobile
            case flipper
        }
    }
}

// MARK: Planning

extension ArchiveSync {
    func resolveActions(
        mobileChanges: [Path: ItemStatus],
        flipperChanges: [Path: ItemStatus]
    ) -> [Path: Action] {
        var result: [Path: Action] = [:]

        for id in Set(mobileChanges.keys).union(flipperChanges.keys) {
            let mobileItemState = mobileChanges[id]
            let flipperItemState = flipperChanges[id]

            // ignore identical changes
            guard mobileItemState != flipperItemState else {
                continue
            }

            switch (mobileItemState, flipperItemState) {
            // changes on mobile
            case let (.some(change), .none):
                switch change {
                case .modified: result[id] = .update(.flipper)
                case .deleted: result[id] = .delete(.flipper)
                }
            // changes on flipper
            case let (.none, .some(change)):
                switch change {
                case .modified: result[id] = .update(.mobile)
                case .deleted: result[id] = .delete(.mobile)
                }
            // changes on both devices
            case let (.some(mobileChange), .some(flipperChange)):
                switch (mobileChange, flipperChange) {
                // modifications override deletions
                case (.deleted, .modified): result[id] = .update(.mobile)
                case (.modified, .deleted): result[id] = .update(.flipper)
                // possible conflicts
                case (.modified, .modified): result[id] = .conflict
                default: fatalError("unreachable")
                }
            default:
                fatalError("unreachable")
            }
        }

        return result
    }
}

// MARK: CustomStringConvertible

extension ArchiveSync.Action: CustomStringConvertible {
    public var description: String {
        switch self {
        case .update(let target): return "update: \(target)"
        case .delete(let target): return "delete \(target)"
        case .conflict: return "conflict"
        }
    }
}

extension ArchiveSync.Action.Target: CustomStringConvertible {
    public var description: String {
        switch self {
        case .mobile: return "mobile"
        case .flipper: return "flipper"
        }
    }
}
