import Inject
import Analytics
import Peripheral

import Logging
import Combine
import Foundation

@MainActor
public class SyncService: ObservableObject {
    private let logger = Logger(label: "sync-service")

    let appState: AppState
    var status: DeviceStatus = .disconnected

    @Inject var rpc: RPC
    @Inject var archive: Archive
    @Inject var analytics: Analytics
    private var disposeBag: DisposeBag = .init()

    public init(appState: AppState) {
        self.appState = appState
        subscribeToPublishers()
    }

    func subscribeToPublishers() {
        appState.$status
            .sink { [weak self] status in
                guard let self else { return }
                let oldValue = self.status
                self.status = status
                self.onStatusChanged(oldValue)
            }
            .store(in: &disposeBag)
    }

    func onStatusChanged(_ oldValue: DeviceStatus) {
        #if !DEBUG
        if oldValue == .connecting, status == .connected {
            self.synchronize(syncDateTime: true)
        }
        #endif
    }

    // MARK: Synchronization

    public func synchronize(syncDateTime: Bool = false) {
        Task {
            do {
                guard appState.status == .connected else { return }
                logger.info("synchronize")
                appState.status = .synchronizing

                appState.syncProgress = 0
                if syncDateTime {
                    try await self.synchronizeDateTime()
                }
                try await checkMFLogFile()
                try await synchronizeArchive()

                appState.status = .synchronized
                try await Task.sleep(nanoseconds: 3_000 * 1_000_000)
                guard appState.status == .synchronized else { return }
                appState.status = .connected
            } catch {
                logger.error("synchronize: \(error)")
            }
        }
    }

    private func checkMFLogFile() async throws {
        appState.hasMFLog = try await rpc.fileExists(at: .mfKey32Log)
    }

    private func synchronizeArchive() async throws {
        let time = try await measure {
            try await archive.synchronize { progress in
                // FIXME: find the issue (very rare)
                guard progress.isNormal else { return }
                Task { @MainActor in
                    appState.syncProgress = Int(progress * 100)
                }
            }
        }
        reportSynchronizationResult(time: time)
        logger.info("syncing archive: (\(time)s)")
    }

    public func cancelSync() {
        archive.cancelSync()
    }

    private func synchronizeDateTime() async throws {
        let time = try await measure {
            try await rpc.setDate(.init())
        }
        logger.info("syncing date: (\(time)s)")
    }

    // MARK: Debug

    func measure(_ task: () async throws -> Void) async rethrows -> Int {
        let start = Date()
        try await task()
        return Int(Date().timeIntervalSince(start) * 1000)
    }

    // MARK: Analytics

    func reportSynchronizationResult(time: Int) {
        analytics.synchronizationResult(
            subGHzCount: archive._items.value.count { $0.kind == .subghz },
            rfidCount: archive._items.value.count { $0.kind == .rfid },
            nfcCount: archive._items.value.count { $0.kind == .nfc },
            infraredCount: archive._items.value.count { $0.kind == .infrared },
            iButtonCount: archive._items.value.count { $0.kind == .ibutton },
            synchronizationTime: time)
    }
}

private extension Array where Element == ArchiveItem {
    func count(_ isIncluded: (Self.Element) -> Bool) -> Int {
        filter(isIncluded).count
    }
}
