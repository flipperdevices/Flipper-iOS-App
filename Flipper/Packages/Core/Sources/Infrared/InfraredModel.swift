import Infrared
import Peripheral

import Combine
import Foundation

@MainActor
public class InfraredModel: ObservableObject {
    private let service: InfraredService
    private let storage: StorageAPI
    private let application: ApplicationAPI
    private let pairedDevice: PairedDevice

    private var isInfraredAppRunning = false

    public init(
        service: InfraredService,
        storage: StorageAPI,
        application: ApplicationAPI,
        pairedDevice: PairedDevice
    ) {
        self.service = service
        self.storage = storage
        self.application = application
        self.pairedDevice = pairedDevice
        subscribeToPublishers()
    }

    public enum Error {
        public enum Network: Swift.Error, Equatable {
            case invalidResponse
            case noInternet
        }
    }

    private func subscribeToPublishers() {
        Task { @MainActor in
            while !Task.isCancelled {
                for await state in await application.state {
                    switch state {
                    case .started:
                        isInfraredAppRunning = true
                    case .closed:
                        isInfraredAppRunning = false
                    case .unknown:
                        logger.critical("unknown app state")
                    }
                }
            }
        }
    }

    public func loadCategories() async throws -> [InfraredCategory] {
        do {
            return try await handlingWebErrors {
                try await service
                    .categories()
                    .categories
                    .map { .init(category: $0) }
            }
        } catch {
            logger.error("load category \(error)")
            throw error
        }
    }

    public func loadBrand(
        _ category: InfraredCategory
    ) async throws -> [InfraredBrand] {
        do {
            return try await handlingWebErrors {
                try await service
                    .brands(forCategoryID: category.id)
                    .brands
                    .map { .init($0, category.id) }
            }
        } catch {
            logger.error("load brand \(error)")
            throw error
        }
    }

    public func loadSignal(
        brand: InfraredBrand,
        successSignals: [Int],
        failedSignals: [Int],
        skippedSignals: [Int]
    ) async throws -> InfraredSelection {
        do {
            return try await handlingWebErrors {
                let response = try await service
                    .signal(
                        forBrandID: brand.id,
                        forCategoryID: brand.categoryID,
                        successSignals: successSignals,
                        failedSignals: failedSignals,
                        skippedSignals: skippedSignals
                    )
                return InfraredSelection(response)
            }
        } catch {
            logger.error("load signal \(error)")
            throw error
        }
    }

    public func loadLayout(
        _ irFile: InfraredFile
    ) async throws -> InfraredLayout {
        do {
            return try await handlingWebErrors {
                let response = try await service.layout(forIfrID: irFile.id)
                return InfraredLayout(response)
            }
        } catch {
            logger.error("load layout \(error)")
            throw error
        }
    }

    public func loadContent(
        _ irFile: InfraredFile
    ) async throws -> InfraredKeyContent {
        do {
            return try await handlingWebErrors {
                let response = try await service.content(forIfrID: irFile.id)
                return InfraredKeyContent(response)
            }
        } catch {
            logger.error("load content \(error)")
            throw error
        }
    }

    public func loadInfraredFiles(
        _ brand: InfraredBrand
    ) async throws -> [InfraredFile] {
        do {
            return try await handlingWebErrors {
                try await service
                    .brandFiles(forBrandID: brand.id)
                    .files
                    .map { InfraredFile($0) }
            }
        } catch {
            logger.error("load ifr files \(error)")
            throw error
        }
    }

    private func handlingWebErrors<T>(
        _ body: () async throws -> T
    ) async rethrows -> T {
        do {
            return try await body()
        } catch let error as URLError {
            logger.error("web: \(error)")
            throw Error.Network.noInternet
        } catch {
            logger.error("web: \(error)")
            throw error
        }
    }

    public func sendTempContent(
        _ content: String,
        _ progress: (Double) -> Void = { _ in }
    ) async throws {
        do {
            try await storage.write(
                at: ArchiveItem.tempIfr.path,
                string: content,
                progress: progress
            )
        } catch {
            logger.error("send temp content \(error)")
            throw error
        }
    }

    public func sendTempLayout(
        _ layout: InfraredLayout,
        _ progress: (Double) -> Void = { _ in }
    ) async throws {
        do {
            guard let path = ArchiveItem.tempIfr.layoutPath else { return }
            try await storage.write(
                at: path,
                string: layout.content ?? "",
                progress: progress
            )
        } catch {
            logger.error("send temp layout \(error)")
            throw error
        }
    }

    public func copyTemp(_ item: ArchiveItem) async throws {
        do {
            try await storage.move(
                at: ArchiveItem.tempIfr.path,
                to: item.path)

            guard
                let fromLayoutPath = ArchiveItem.tempIfr.layoutPath,
                let toLayoutPath = item.layoutPath
            else { return }

            try await storage.move(
                at: fromLayoutPath,
                to: toLayoutPath)
        } catch {
            logger.error("copy temp \(error)")
            throw error
        }
    }
}

public extension Array where Element == ArchiveItem.Property {
    func getIndex(by keyId: InfraredKeyID) -> Int? {
        guard let name = keyId.name else { return nil }
        let names = self.filter({$0.key == "name"}).map { $0.value }

        return names.firstIndex(where: { $0 == name })
    }
}

public extension Array where Element == ArchiveItem.InfraredSignal {
    func getIndex(keyId: InfraredKeyID) -> Int? {
        return switch keyId {
        case .name(let keyId):
            self.getIndex(name: keyId.name)
        case .sha256(let keyId):
            self.getIndex(hash: keyId.hash)
        case .unknown:
            nil
        }
    }
}

public extension ArchiveItem {
    static let tempIfr: ArchiveItem = .init(
        name: ".tmp",
        kind: .infrared,
        properties: [],
        shadowCopy: []
    )
}
