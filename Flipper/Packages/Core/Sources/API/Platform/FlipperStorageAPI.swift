import Peripheral

import Foundation

class FlipperStorageAPI: StorageAPI {
    private var rpc: Session { pairedDevice.session }
    private let pairedDevice: PairedDevice

    init(pairedDevice: PairedDevice) {
        self.pairedDevice = pairedDevice
    }

    func space(of path: Path) async throws -> Peripheral.StorageSpace {
        try await rpc.getStorageInfo(at: path)
    }

    func list(
        at path: Path,
        calculatingMD5: Bool,
        sizeLimit: Int
    ) async throws -> [Element] {
        try await rpc.listDirectory(
            at: path,
            calculatingMD5: calculatingMD5,
            sizeLimit: sizeLimit)
    }

    func size(of path: Path) async throws -> Int {
        try await rpc.getSize(at: path)
    }

    func hash(of path: Path) async throws -> Peripheral.Hash {
        try await rpc.calculateFileHash(at: path)
    }

    func timestamp(of path: Path) async throws -> Date {
        try await rpc.getTimestamp(at: path)
    }

    func create(at path: Path, isDirectory: Bool) async throws {
        try await rpc.createFile(at: path, isDirectory: isDirectory)
    }

    func delete(at path: Path, force: Bool) async throws {
        try await rpc.deleteFile(at: path, force: force)
    }

    func read(at path: Path) -> ByteStream {
        rpc.readFile(at: path)
    }

    func write(at path: Path, bytes: [UInt8]) -> ByteCountStream {
        rpc.writeFile(at: path, bytes: bytes)
    }

    func move(at path: Path, to dest: Path) async throws {
        try await rpc.moveFile(from: path, to: dest)
    }
}
