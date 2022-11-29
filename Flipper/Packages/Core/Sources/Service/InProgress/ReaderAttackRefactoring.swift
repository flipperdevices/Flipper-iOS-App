import Inject
import Peripheral

import Logging
import Combine
import Foundation

// TODO: Refactor (ex ReaderAttackViewModel)

@MainActor
public class ReaderAttackRefactoring: ObservableObject {
    private let logger = Logger(label: "reader-attack-vm")

    @Inject private var rpc: RPC
    @Inject private var appState: AppState
    private var disposeBag: DisposeBag = .init()

    @Published public var flipper: Flipper? {
        didSet {
            if flipper?.state != .connected {
                state = .noDevice
            }
        }
    }
    public var flipperColor: FlipperColor {
        flipper?.color ?? .white
    }

    public var isAttackInProgress: Bool {
        !isError && state != .finished
    }

    public var isError: Bool {
        state == .noLog || state == .noDevice || state == .noSDCard
    }

    public var hasMFKey32Log: Bool {
        get async throws {
            try await rpc.fileExists(at: .mfKey32Log)
        }
    }

    @Published public var state: State = .downloadingLog
    @Published public var showCancelAttack = false
    @Published public var progress: Double = 0
    @Published public var results: [ReaderAttack.Result] = []
    @Published public var newKeys: Set<MFKey64> = .init()
    @Published public var flipperDuplicatedKeys: Set<MFKey64> = .init()
    @Published public var userDuplicatedKeys: Set<MFKey64> = .init()

    private var forceStop = false
    private let mfKnownKeys = MFKnownKeys()
    private var flipperKnownKeys: Set<MFKey64> = .init()
    private var userKnownKeys: Set<MFKey64> = .init()
    private var allKnownKeys: Set<MFKey64> {
        flipperKnownKeys.union(userKnownKeys)
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

    public init() {
        appState.$flipper
            .receive(on: DispatchQueue.main)
            .assign(to: \.flipper, on: self)
            .store(in: &disposeBag)
    }

    var task: Task<Void, Never>?

    public func start() {
        task = Task {
            do {
                try await start()
            } catch where error is CancellationError {
                logger.error("mfkey32 attack canceled")
            } catch {
                logger.error("mfkey32 attack: \(error)")
            }
        }
    }

    private func start() async throws {
        do {
            guard flipper?.state == .connected else {
                return
            }
            guard try await hasMFKey32Log else {
                state = .noLog
                return
            }
            state = .downloadingLog
            let log = try await readLog()
            state = .calculating
            try await calculateKeys(log)
            state = .checkingKeys
            try await checkKeys()
            state = .uploadingKeys
            try await uploadKeys()
            try await deleteLog()
            state = .finished
        } catch let error as Error where error == .storage(.internal) {
            state = .noSDCard
            logger.error("mfkey32 attack: no sd card")
        }
    }

    public func stop() {
        task?.cancel()
    }

    private func readLog() async throws -> String {
        try Task.checkCancellation()
        return try await rpc.readFile(at: .mfKey32Log) { progress in
            Task { @MainActor in
                self.progress = progress
            }
        }
    }

    private func deleteLog() async throws {
        try await rpc.deleteFile(at: .mfKey32Log)
        appState.hasMFLog = false
    }

    private func calculateKeys(_ logFile: String) async throws {
        let readerLog = try ReaderLog(logFile)
        let count = readerLog.lines.count
        progress = 0
        for await result in ReaderAttack.recoverKeys(from: readerLog) {
            results.append(result)
            progress = Double(results.count) / Double(count)
        }
    }

    private func checkKeys() async throws {
        try Task.checkCancellation()
        self.flipperKnownKeys = try await mfKnownKeys.readFlipperKeys()
        try Task.checkCancellation()
        self.userKnownKeys = try await mfKnownKeys.readUserKeys()

        let foundKeysSet = Set(keysFound)

        self.newKeys = .init(foundKeysSet.subtracting(allKnownKeys))
        self.flipperDuplicatedKeys = foundKeysSet.intersection(flipperKnownKeys)
        self.userDuplicatedKeys = foundKeysSet.intersection(userKnownKeys)
    }

    private func uploadKeys() async throws {
        try Task.checkCancellation()
        try await mfKnownKeys.writeUserKeys(userKnownKeys.union(newKeys))
    }
}
