import Foundation

class FirmwareProvider {
    public func data(
        from url: URL,
        progress: @escaping (Double) -> Void
    ) async throws -> [UInt8] {
        url.isFileURL
            ? try await readFile(url, progress: progress)
            : try await download(url, progress: progress)
    }

    func download(
        _ url: URL,
        progress: @escaping (Double) -> Void
    ) async throws -> [UInt8] {
        logger.info("downloading firmware \(url)")
        return try await URLSessionData(from: url) {
            progress($0.fractionCompleted)
        }.bytes
    }

    func readFile(
        _ url: URL,
        progress: @escaping (Double) -> Void
    ) async throws -> [UInt8] {
        defer { progress(1.0) }
        switch try? Data(contentsOf: url) {
        case .some: return try await readLocalFile(from: url)
        case .none: return try await readCloudFile(from: url)
        }
    }

    private func readLocalFile(from url: URL) async throws -> [UInt8] {
        logger.debug("reading local firmware: \(url.lastPathComponent)")
        let data = try Data(contentsOf: url)
        // remove item passed from another app
        if url.path.starts(with: "/private") {
            try FileManager.default.removeItem(at: url)
        }
        return .init(data)
    }

    private  func readCloudFile(from url: URL) async throws -> [UInt8] {
        #if canImport(UIKit)
        logger.debug("reading cloud firmware: \(url.lastPathComponent)")
        let doc = await CloudDocument(fileURL: url)
        guard await doc.open(), let data = await doc.data else {
            throw Update.Error.invalidFirmwareCloudDocument
        }
        return .init(data)
        #else
        throw Update.Error.invalidFirmwareCloudDocument
        #endif
    }
}
