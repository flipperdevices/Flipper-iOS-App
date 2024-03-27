@testable import Core
@testable import Peripheral

import XCTest

class ArchiveTests: XCTestCase {
    let keyPath: Path = "/any/nfc/key.nfc"
    let keyContent: String = "content"

    func testFlipperManifest() async throws {
        let archive = FlipperArchive(storage: InMemoryStorageAPI())
        try await _testManifest(archive: archive)
    }

    func testOlderFlipperManifest() async throws {
        let archive = FlipperArchive(storage: OldFlipperStorageAPI())
        try await _testManifest(archive: archive)
    }

    func testFlipperArchive() async throws {
        let archive = FlipperArchive(storage: InMemoryStorageAPI())
        try await _testArchive(archive: archive)
    }

    func testMobileManifest() async throws {
        let archive = MobileArchive(storage: InMemoryStorageAPI(entries: [
            "mobile": .directory(.init(entries: [
                "any": .directory(.init())
            ]))
        ]))
        try await _testManifest(archive: archive)
    }

    func testMobileArchive() async throws {
        let archive = MobileArchive(storage: InMemoryStorageAPI(entries: [
            "mobile": .directory(.init(entries: [
                "any": .directory(.init())
            ]))
        ]))
        try await _testArchive(archive: archive)
    }

    // MARK: Common

    func _testManifest(
        archive: ArchiveProtocol,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async throws {
        try await archive.upsert(keyContent, at: keyPath) { _ in }
        let manifest = try await archive.getManifest()

        XCTAssertEqual(
            manifest.items,
            [keyPath: .init(keyContent.md5)],
            file: file,
            line: line
        )
    }

    func _testArchive(archive: ArchiveProtocol) async throws {
        // MARK: upsert

        var progress: [Double] = []
        try await archive.upsert(keyContent, at: keyPath) {
            progress.append($0)
        }
        XCTAssertEqual(progress, [1.0])

        // MARK: read

        progress.removeAll()
        let content = try await archive.read(keyPath) {
            progress.append($0)
        }
        XCTAssertEqual(progress, [1.0])
        XCTAssertEqual(content, keyContent)

        // MARK: delete

        try await archive.delete(keyPath)

        do {
            _ = try await archive.read(keyPath)
            XCTFail("didn't throw an error")
        } catch {
            guard let error = error as? Error.StorageError else {
                XCTFail("read error is not StorageError ")
                return
            }
            XCTAssertEqual(error, .doesNotExist)
        }
    }

    // MARK: Compat tests

    class OldFlipperStorageAPI: InMemoryStorageAPI {
        override func list(
            at path: Path,
            calculatingMD5: Bool,
            sizeLimit: Int
        ) async throws -> [Element] {
            try await super.list(at: path, calculatingMD5: false, sizeLimit: 0)
        }
    }
}
