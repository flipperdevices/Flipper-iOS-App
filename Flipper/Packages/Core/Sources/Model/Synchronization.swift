import Peripheral

import Combine
import Foundation

@MainActor
public class Synchronization: ObservableObject {
    // next step
    let device: Device

    @Published public private(set) var progress: Progress = .prepare

    private var system: SystemAPI
    private var storage: StorageAPI

    private var archive: Archive
    private var cancellables: [AnyCancellable] = .init()

    private var isSyncingDisabled: Bool {
        UserDefaultsStorage.shared.isSyncingDisabled
    }

    public enum Progress: Equatable {
        case prepare
        case syncManifest(Double)
        case syncFile(Double, String)
        case done

        public var value: Int {
            return switch self {
            case .prepare: 0
            case .syncManifest(let value): Int(value * 100)
            case .syncFile(let value, _): Int(value * 100)
            case .done: 100
            }
        }
    }

    init(
        archive: Archive,
        device: Device,
        system: SystemAPI,
        storage: StorageAPI
    ) {
        self.archive = archive
        self.device = device
        self.system = system
        self.storage = storage

        subscribeToPublishers()
    }

    // next step
    var deviceStatus: Device.Status = .disconnected {
        didSet {
            guard !isSyncingDisabled else { return }
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

                progress = .prepare

                if syncDateTime {
                    try await self.synchronizeDateTime()
                }
                try await synchronizeMFLogFile()
                try await synchronizeArchive()

                device.status = .synchronized
                try await Task.sleep(nanoseconds: 3_000 * 1_000_000)
                guard device.status == .synchronized else { return }
                device.status = .connected
            } catch {
                logger.error("synchronize: \(error)")
                if device.status == .synchronizing {
                    device.status = .connected
                }
            }
        }
    }

    private func synchronizeMFLogFile() async throws {
        UserDefaultsStorage.shared.hasReaderLog =
            try await storage.fileExists(at: .mfKey32Log)
    }

    private func synchronizeArchive() async throws {
        var changesCount = 0
        let time = try await measure {
            changesCount = try await archive.synchronize { progress in
                Task { @MainActor in
                    self.progress = progress
                }
            }
        }
        reportSynchronizationResult(time: time, changesCount: changesCount)
        logger.info("syncing archive: \(time) ms")
    }

    public func cancelSync() {
        archive.cancelSync()
    }

    private func synchronizeDateTime() async throws {
        let time = try await measure {
            try await system.setDate(.init())
        }
        logger.info("syncing date: \(time) ms")
    }

    // MARK: Debug

    func measure(_ task: () async throws -> Void) async rethrows -> Int {
        let start = Date()
        try await task()
        return Int(Date().timeIntervalSince(start) * 1_000)
    }

    // MARK: Analytics

    func reportSynchronizationResult(time: Int, changesCount: Int) {
        analytics.synchronizationResult(
            subGHzCount: archive._items.value.count { $0.kind == .subghz },
            rfidCount: archive._items.value.count { $0.kind == .rfid },
            nfcCount: archive._items.value.count { $0.kind == .nfc },
            infraredCount: archive._items.value.count { $0.kind == .infrared },
            iButtonCount: archive._items.value.count { $0.kind == .ibutton },
            synchronizationTime: time,
            changesCount: changesCount)
    }
}

private extension Array where Element == ArchiveItem {
    func count(_ isIncluded: (Self.Element) -> Bool) -> Int {
        filter(isIncluded).count
    }
}
