import Peripheral

import Combine
import Foundation

@MainActor
public class Synchronization: ObservableObject {
    // next step
    let device: Device

    @Published public var progress: Int = 0

    private var pairedDevice: PairedDevice
    private var rpc: RPC { pairedDevice.session }

    private var archive: Archive
    private var cancellables: [AnyCancellable] = .init()

    init(pairedDevice: PairedDevice, archive: Archive, device: Device) {
        self.pairedDevice = pairedDevice
        self.archive = archive
        self.device = device

        subscribeToPublishers()
    }

    // next step
    var deviceStatus: Device.Status = .disconnected {
        didSet {
            #if !DEBUG
            if oldValue == .connecting, deviceStatus == .connected {
                self.start(syncDateTime: true)
            }
            #endif
        }
    }

    func subscribeToPublishers() {
        device.$status
            .receive(on: DispatchQueue.main)
            .assign(to: \.deviceStatus, on: self)
            .store(in: &cancellables)
    }

    // MARK: Synchronization

    public func start(syncDateTime: Bool = false) {
        Task {
            do {
                guard device.status == .connected else { return }
                logger.info("synchronize")
                device.status = .synchronizing

                progress = 0
                if syncDateTime {
                    try await self.synchronizeDateTime()
                }
                try await checkMFLogFile()
                try await synchronizeArchive()

                device.status = .synchronized
                try await Task.sleep(nanoseconds: 3_000 * 1_000_000)
                guard device.status == .synchronized else { return }
                device.status = .connected
            } catch {
                logger.error("synchronize: \(error)")
            }
        }
    }

    private func checkMFLogFile() async throws {
        UserDefaultsStorage.shared.hasReaderLog =
            try await rpc.fileExists(at: .mfKey32Log)
    }

    private func synchronizeArchive() async throws {
        let time = try await measure {
            try await archive.synchronize { progress in
                // FIXME: find the issue (very rare)
                guard progress.isNormal else { return }
                Task { @MainActor in
                    self.progress = Int(progress * 100)
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
