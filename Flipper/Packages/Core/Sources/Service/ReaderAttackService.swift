import Inject
import Peripheral

import Logging
import Combine
import Foundation

@MainActor
public class ReaderAttackService: ObservableObject {
    let appState: AppState

    var readerAttack: ReaderAttackModel {
        get { appState.readerAttack }
        set { appState.readerAttack = newValue }
    }

    @Inject private var rpc: RPC
    @Inject var pairedDevice: PairedDevice
    private var disposeBag: DisposeBag = .init()

    @Published public var flipper: Flipper? {
        didSet {
            if flipper?.state != .connected {
                readerAttack.state = .noDevice
            }
        }
    }

    public var hasReaderLog: Bool {
        get { UserDefaultsStorage.shared.hasReaderLog }
        set { UserDefaultsStorage.shared.hasReaderLog = newValue }
    }

    private var forceStop = false
    private let mfKnownKeys = MFKnownKeys()

    public init(appState: AppState) {
        self.appState = appState
        subscribeToPublishers()
    }

    func subscribeToPublishers() {
        pairedDevice.flipper
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

    public func cancel() {
        readerAttack.showCancelAttack = true
    }

    private func start() async throws {
        do {
            guard flipper?.state == .connected else {
                return
            }
            await checkLog()
            guard hasReaderLog else {
                readerAttack.state = .noLog
                return
            }
            readerAttack = .init()
            readerAttack.state = .downloadingLog
            let log = try await readLog()
            readerAttack.state = .calculating
            try await calculateKeys(log)
            readerAttack.state = .checkingKeys
            try await checkKeys()
            readerAttack.state = .uploadingKeys
            try await uploadKeys()
            try await deleteLog()
            readerAttack.state = .finished
        } catch let error as Error where error == .storage(.internal) {
            readerAttack.state = .noSDCard
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
                readerAttack.progress = progress
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
        readerAttack.progress = 0
        for await result in ReaderAttack.recoverKeys(from: readerLog) {
            readerAttack.results.append(result)
            readerAttack.progress = Double(readerAttack.results.count) / total
        }
    }

    private func checkKeys() async throws {
        try Task.checkCancellation()
        readerAttack.flipperKnownKeys = try await mfKnownKeys.readFlipperKeys()
        try Task.checkCancellation()
        readerAttack.userKnownKeys = try await mfKnownKeys.readUserKeys()
    }

    private func uploadKeys() async throws {
        try Task.checkCancellation()
        try await mfKnownKeys.writeUserKeys(readerAttack.newUserKnownKeys)
    }
}
