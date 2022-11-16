import Core
import Inject
import Combine
import Peripheral
import Foundation
import Logging

@MainActor
class ReaderAttackViewModel: ObservableObject {
    private let logger = Logger(label: "reader-attack-vm")

    @Inject private var rpc: RPC
    @Inject private var appState: AppState
    private var disposeBag: DisposeBag = .init()

    @Published var flipper: Flipper? {
        didSet {
            if flipper?.state != .connected {
                state = .noDevice
            }
        }
    }
    var flipperColor: FlipperColor {
        flipper?.color ?? .white
    }

    var isAttackInProgress: Bool {
        !isError && state != .finished
    }

    var isError: Bool {
        state == .noLog || state == .noDevice || state == .noSDCard
    }

    var hasMFKey32Log: Bool {
        get async {
            (try? await rpc.fileExists(at: .mfKey32Log)) == true
        }
    }

    @Published var state: State = .downloadingLog
    @Published var showCancelAttack = false
    @Published var progress: Double = 0
    @Published var results: [ReaderAttack.Result] = []
    @Published var newKeys: Set<MFKey64> = .init()
    @Published var flipperDuplicatedKeys: Set<MFKey64> = .init()
    @Published var userDuplicatedKeys: Set<MFKey64> = .init()

    private var forceStop = false
    private let mfKnownKeys = MFKnownKeys()
    private var flipperKnownKeys: Set<MFKey64> = .init()
    private var userKnownKeys: Set<MFKey64> = .init()
    private var allKnownKeys: Set<MFKey64> {
        flipperKnownKeys.union(userKnownKeys)
    }

    var progressString: String {
        "\(Int(progress * 100)) %"
    }

    var showCalculatedKeysSpinner: Bool {
        results.isEmpty && state != .finished
    }

    var hasNewKeys: Bool {
        !newKeys.isEmpty
    }

    var hasDuplicatedKeys: Bool {
        !(flipperDuplicatedKeys.isEmpty && userDuplicatedKeys.isEmpty)
    }

    var keysFound: [MFKey64] {
        results.compactMap { $0.key }
    }

    enum State {
        case noLog
        case noDevice
        case noSDCard
        case downloadingLog
        case calculating
        case checkingKeys
        case uploadingKeys
        case finished
    }

    init() {
        appState.$flipper
            .receive(on: DispatchQueue.main)
            .assign(to: \.flipper, on: self)
            .store(in: &disposeBag)
    }

    var task: Task<Void, Never>?

    func start() {
        task = Task {
            do {
                guard await hasMFKey32Log else {
                    state = .noLog
                    return
                }
                state = .downloadingLog
                let log = try await readLog()
                state = .calculating
                try await calculateKeys(log)
                do {
                    state = .checkingKeys
                    try await checkKeys()
                    state = .uploadingKeys
                    try await uploadKeys()
                    try await deleteLog()
                } catch let error as Error where error == .storage(.internal) {
                    self.state = .noSDCard
                    throw error
                }
                state = .finished
            } catch where error is CancellationError {
                logger.error("mfkey32 attack canceled")
            } catch {
                logger.error("mfkey32 attack: \(error)")
            }
        }
    }

    func stop() {
        task?.cancel()
    }

    func readLog() async throws -> String {
        try Task.checkCancellation()
        return try await rpc.readFile(at: .mfKey32Log) { progress in
            Task { @MainActor in
                self.progress = progress
            }
        }
    }

    func deleteLog() async throws {
        try await rpc.deleteFile(at: .mfKey32Log)
        appState.hasMFLog = false
    }

    func calculateKeys(_ logFile: String) async throws {
        let readerLog = try ReaderLog(logFile)
        let count = readerLog.lines.count
        progress = 0
        for await result in ReaderAttack.recoverKeys(from: readerLog) {
            results.append(result)
            progress = Double(results.count) / Double(count)
        }
    }

    func checkKeys() async throws {
        try Task.checkCancellation()
        self.flipperKnownKeys = try await mfKnownKeys.readFlipperKeys()
        try Task.checkCancellation()
        self.userKnownKeys = try await mfKnownKeys.readUserKeys()

        let foundKeysSet = Set(keysFound)

        self.newKeys = .init(foundKeysSet.subtracting(allKnownKeys))
        self.flipperDuplicatedKeys = foundKeysSet.intersection(flipperKnownKeys)
        self.userDuplicatedKeys = foundKeysSet.intersection(userKnownKeys)
    }

    func uploadKeys() async throws {
        try Task.checkCancellation()
        try await mfKnownKeys.writeUserKeys(userKnownKeys.union(newKeys))
    }
}
