import Peripheral

import Combine
import Foundation

@MainActor
public class DetectReader: ObservableObject {
    @Published public var state: State = .downloadingLog
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

    private let pairedDevice: PairedDevice
    private var rpc: RPC { pairedDevice.session }
    private var cancellables: [AnyCancellable] = .init()

    @Published public var flipper: Flipper? {
        didSet {
            if flipper?.state != .connected {
                state = .noDevice
            }
        }
    }

    public var hasReaderLog: Bool {
        get { UserDefaultsStorage.shared.hasReaderLog }
        set { UserDefaultsStorage.shared.hasReaderLog = newValue }
    }

    private var forceStop = false
    private let mfKnownKeys: MFKnownKeys

    public init(pairedDevice: PairedDevice) {
        self.pairedDevice = pairedDevice
        // next step
        self.mfKnownKeys = .init(pairedDevice: pairedDevice)

        subscribeToPublishers()
    }

    public convenience init() {
        self.init(pairedDevice: Dependencies.shared.pairedDevice)
    }

    func subscribeToPublishers() {
        pairedDevice.flipper
            .receive(on: DispatchQueue.main)
            .assign(to: \.flipper, on: self)
            .store(in: &cancellables)
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
            await checkLog()
            guard hasReaderLog else {
                state = .noLog
                return
            }
            reportMFKey32Started()
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

    public func checkLog() async {
        do {
            hasReaderLog = try await rpc.fileExists(at: .mfKey32Log)
        } catch {
            logger.error("check log: \(error)")
        }
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
        hasReaderLog = false
    }

    private func calculateKeys(_ logFile: String) async throws {
        let readerLog = try ReaderLog(logFile)
        let total = Double(readerLog.lines.count)
        progress = 0
        for await result in ReaderAttack.recoverKeys(from: readerLog) {
            results.append(result)
            progress = Double(results.count) / total
        }
    }

    private func checkKeys() async throws {
        try Task.checkCancellation()
        flipperKnownKeys = try await mfKnownKeys.readFlipperKeys()
        try Task.checkCancellation()
        userKnownKeys = try await mfKnownKeys.readUserKeys()
    }

    private func uploadKeys() async throws {
        try Task.checkCancellation()
        try await mfKnownKeys.writeUserKeys(newUserKnownKeys)
    }

    private func reportMFKey32Started() {
        analytics.appOpen(target: .mfKey32)
    }
}
