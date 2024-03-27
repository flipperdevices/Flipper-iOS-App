@testable import Core
@testable import Peripheral

import XCTest

class FileSystemManifestTests: XCTestCase {
    func testEmptyManifest() async throws {
        let inMemoryStorage = InMemoryManifestAPI(entries: [:])
        let fsManifest = FileSystemManifest(listing: inMemoryStorage)

        var progress: [Double] = []
        let (manifest, knownDirectories) = try await fsManifest.get(at: "/") {
            progress.append($0)
        }
        XCTAssertEqual(progress, [1.0])

        XCTAssertEqual(manifest.items, [:])
        XCTAssertEqual(knownDirectories.paths, [])

        // NOTE: test that we don't create asset directories
        let any = try await inMemoryStorage.list(at: "/")
        XCTAssertEqual(any.count, 0)
    }

    func testSimpleManifest() async throws {
        let inMemoryStorage = InMemoryManifestAPI(entries: [
            "nfc": .directory(.init(entries: [
                "key.nfc": .file(.init(content: "content"))
            ]))
        ])
        let fsManifest = FileSystemManifest(listing: inMemoryStorage)

        let (manifest, knownDirectories) = try await fsManifest.get(at: "/") 
        { _ in }

        XCTAssertEqual(manifest.items, [
            "/nfc/key.nfc": .init("content".md5)
        ])
        XCTAssertEqual(knownDirectories.paths, ["/nfc"])
    }

    func testShadowFile() async throws {
        let inMemoryStorage = InMemoryManifestAPI(entries: [
            "nfc": .directory(.init(entries: [
                "key.nfc": .file(.init(content: "content")),
                "key.shd": .file(.init(content: "shadow"))
            ]))
        ])
        let fsManifest = FileSystemManifest(listing: inMemoryStorage)
        let (manifest, _) = try await fsManifest.get(at: "/") { _ in }

        XCTAssertEqual(manifest.items, [
            "/nfc/key.nfc": .init("content".md5),
            "/nfc/key.shd": .init("shadow".md5)
        ])
    }

    func testAllKnownFolders() async throws {
        let inMemoryStorage = InMemoryManifestAPI(entries: [
            "lfrfid": .directory(.init(entries: [:])),
            "subghz": .directory(.init(entries: [:])),
            "nfc": .directory(.init(entries: [:])),
            "infrared": .directory(.init(entries: [:])),
            "ibutton": .directory(.init(entries: [:]))
        ])
        let fsManifest = FileSystemManifest(listing: inMemoryStorage)

        var progress: [Double] = []
        let (manifest, knownDirectories) = try await fsManifest.get(at: "/") {
            progress.append($0)
        }
        XCTAssertEqual(
            progress,
            [0.16, 0.33, 0.5, 0.66, 0.83, 1.0],
            accuracy: 0.01
        )

        XCTAssertEqual(manifest.items, [:])
        XCTAssertEqual(knownDirectories.paths, [
            "/lfrfid",
            "/subghz",
            "/nfc",
            "/infrared",
            "/ibutton"
        ])
    }

    func testManifestFilter() async throws {
        let oversize = String(repeating: "-", count: 11 * 1024 * 1024)

        let inMemoryStorage = InMemoryManifestAPI(entries: [
            "nfc": .directory(.init(entries: [
                "key.nfc": .file(.init(content: "content")),
                "._key.nfc": .file(.init(content: "info")),
                "key.sub": .file(.init(content: "wave")),
                "oversize.nfc": .file(.init(content: oversize))
            ]))
        ])
        let fsManifest = FileSystemManifest(listing: inMemoryStorage)

        let (manifest, knownDirectories) = try await fsManifest.get(at: "/") { _ in }

        XCTAssertEqual(manifest.items, [
            "/nfc/key.nfc": .init("content".md5)
        ])
        XCTAssertEqual(knownDirectories.paths, ["/nfc"])
    }
}
