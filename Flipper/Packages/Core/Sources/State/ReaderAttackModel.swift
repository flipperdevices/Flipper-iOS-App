public struct ReaderAttackModel {
    public var state: State = .downloadingLog
    var flipperKnownKeys: Set<MFKey64> = .init()
    var userKnownKeys: Set<MFKey64> = .init()

    var newUserKnownKeys: Set<MFKey64> {
        userKnownKeys.union(newKeys)
    }

    public enum State {
        case noLog
        case noDevice
        case noSDCard
        case downloadingLog
        case calculating
        case checkingKeys
        case uploadingKeys
        case finished
    }

    public var progress: Double = 0
    public var showCancelAttack = false
    public var results: [ReaderAttack.Result] = []

    public var inProgress: Bool {
        !isError && state != .finished
    }

    public var isError: Bool {
        state == .noLog || state == .noDevice || state == .noSDCard
    }

    public var showCalculatedKeysSpinner: Bool {
        results.isEmpty && state != .finished
    }

    public var hasNewKeys: Bool {
        !newKeys.isEmpty
    }

    public var hasDuplicatedKeys: Bool {
        !(flipperDuplicatedKeys.isEmpty && userDuplicatedKeys.isEmpty)
    }

    public var keysFound: [MFKey64] {
        results.compactMap { $0.key }
    }

    public var newKeys: Set<MFKey64> {
        Set(keysFound).subtracting(flipperKnownKeys.union(userKnownKeys))
    }
    public var flipperDuplicatedKeys: Set<MFKey64> {
        Set(keysFound).intersection(flipperKnownKeys)
    }
    public var userDuplicatedKeys: Set<MFKey64> {
        Set(keysFound).intersection(userKnownKeys)
    }
}
