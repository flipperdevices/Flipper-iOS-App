import Bluetooth
// swiftlint:disable nesting cyclomatic_complexity

extension Synchronization {
    enum Action {
        case update(Target)
        case delete(Target)
        case conflict

        enum Target {
            case mobile
            case peripheral
        }
    }
}

// MARK: Planning

extension Synchronization {
    func resolveActions(
        mobileChanges: [Path: ItemStatus],
        peripheralChanges: [Path: ItemStatus]
    ) -> [Path: Action] {
        var result: [Path: Action] = [:]

        for id in Set(mobileChanges.keys).union(peripheralChanges.keys) {
            let mobileItemState = mobileChanges[id]
            let peripheralItemState = peripheralChanges[id]

            // ignore identical changes
            guard mobileItemState != peripheralItemState else {
                continue
            }

            switch (mobileItemState, peripheralItemState) {
            // changes on mobile
            case let (.some(change), .none):
                switch change {
                case .modified: result[id] = .update(.peripheral)
                case .deleted: result[id] = .delete(.peripheral)
                }
            // changes on peripheral
            case let (.none, .some(change)):
                switch change {
                case .modified: result[id] = .update(.mobile)
                case .deleted: result[id] = .delete(.mobile)
                }
            // changes on both devices
            case let (.some(mobileChange), .some(peripheralChange)):
                switch (mobileChange, peripheralChange) {
                // modifications override deletions
                case (.deleted, .modified): result[id] = .update(.mobile)
                case (.modified, .deleted): result[id] = .update(.peripheral)
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

extension Synchronization.Action: CustomStringConvertible {
    public var description: String {
        switch self {
        case .update(let target): return "update: \(target)"
        case .delete(let target): return "delete \(target)"
        case .conflict: return "confilct"
        }
    }
}

extension Synchronization.Action.Target: CustomStringConvertible {
    public var description: String {
        switch self {
        case .mobile: return "mobile"
        case .peripheral: return "peripheral"
        }
    }
}
