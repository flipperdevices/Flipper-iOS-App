@testable import Core
@testable import Peripheral

import XCTest

class ArchiveSyncTests: XCTestCase {
    func testSyncNoChanges() async throws {
        let flipperArchive = InMemoryArchive()
        let mobileArchive = InMemoryArchive()
        let manifest = InMemoryManifest()

        let archiveSync = ArchiveSync(
            flipperArchive: flipperArchive,
            mobileArchive: mobileArchive,
            syncedManifest: manifest)

        var progress: [Double] = []
        let changesCount = try await archiveSync.run {
            progress.append($0)
        }
        XCTAssertEqual(progress, [0.5, 1.0])
        XCTAssertEqual(changesCount, 0)
    }

    func testSyncUpdateOnFlipper() async throws {
        let flipperArchive = InMemoryArchive()
        let mobileArchive = InMemoryArchive()
        let manifest = InMemoryManifest()

        try await mobileArchive.upsert("content", at: "/any/nfc/key.nfc")

        let archiveSync = ArchiveSync(
            flipperArchive: flipperArchive,
            mobileArchive: mobileArchive,
            syncedManifest: manifest)

        var progress: [Double] = []
        let changesCount = try await archiveSync.run {
            progress.append($0)
        }
        XCTAssertEqual(progress, [0.5, 1.0])
        XCTAssertEqual(changesCount, 1)

        let key = try await flipperArchive.read("/any/nfc/key.nfc")
        XCTAssertEqual(key, "content")

        let items = try await manifest.get().items
        XCTAssertEqual(items, ["/any/nfc/key.nfc": Hash("content".md5)])
    }

    func testSyncUpdateOnMobile() async throws {
        let flipperArchive = InMemoryArchive()
        let mobileArchive = InMemoryArchive()
        let manifest = InMemoryManifest()

        try await flipperArchive.upsert("content", at: "/any/nfc/key.nfc")

        let archiveSync = ArchiveSync(
            flipperArchive: flipperArchive,
            mobileArchive: mobileArchive,
            syncedManifest: manifest)

        var progress: [Double] = []
        let changesCount = try await archiveSync.run {
            progress.append($0)
        }
        XCTAssertEqual(progress, [0.5, 1.0])
        XCTAssertEqual(changesCount, 1)

        let key = try await mobileArchive.read("/any/nfc/key.nfc")
        XCTAssertEqual(key, "content")

        let items = try await manifest.get().items
        XCTAssertEqual(items, ["/any/nfc/key.nfc": Hash("content".md5)])
    }

    func testDeleteOnMobile() async throws {
        let flipperArchive = InMemoryArchive()
        let mobileArchive = InMemoryArchive()
        let manifest = InMemoryManifest()

        try await mobileArchive.upsert("content", at: "/any/nfc/key.nfc")
        try await manifest.upsert(.init([
            "/any/nfc/key.nfc": Hash("content".md5)
        ]))

        let archiveSync = ArchiveSync(
            flipperArchive: flipperArchive,
            mobileArchive: mobileArchive,
            syncedManifest: manifest)

        var progress: [Double] = []
        let changesCount = try await archiveSync.run {
            progress.append($0)
        }
        XCTAssertEqual(progress, [0.5, 1.0])
        XCTAssertEqual(changesCount, 1)

        do {
            _ = try await mobileArchive.read("/any/nfc/key.nfc")
            XCTFail("the call should throw")
        } catch {
            let items = try await manifest.get().items
            XCTAssertEqual(items, [:])
        }
    }

    func testDeleteOnFlipper() async throws {
        let flipperArchive = InMemoryArchive()
        let mobileArchive = InMemoryArchive()
        let manifest = InMemoryManifest()

        try await flipperArchive.upsert("content", at: "/any/nfc/key.nfc")
        try await manifest.upsert(.init([
            "/any/nfc/key.nfc": Hash("content".md5)
        ]))

        let archiveSync = ArchiveSync(
            flipperArchive: flipperArchive,
            mobileArchive: mobileArchive,
            syncedManifest: manifest)

        var progress: [Double] = []
        let changesCount = try await archiveSync.run {
            progress.append($0)
        }
        XCTAssertEqual(progress, [0.5, 1.0])
        XCTAssertEqual(changesCount, 1)

        do {
            _ = try await flipperArchive.read("/any/nfc/key.nfc")
            XCTFail("the call should throw")
        } catch {
            let items = try await manifest.get().items
            XCTAssertEqual(items, [:])
        }
    }

    func testSyncKeepBoth() async throws {
        let flipperArchive = InMemoryArchive()
        let mobileArchive = InMemoryArchive()
        let manifest = InMemoryManifest()

        try await mobileArchive.upsert("one", at: "/any/nfc/key.nfc")
        try await flipperArchive.upsert("two", at: "/any/nfc/key.nfc")

        let archiveSync = ArchiveSync(
            flipperArchive: flipperArchive,
            mobileArchive: mobileArchive,
            syncedManifest: manifest)

        var progress: [Double] = []
        let changesCount = try await archiveSync.run {
            progress.append($0)
        }
        XCTAssertEqual(progress, [0.5, 0.75, 1.0])
        XCTAssertEqual(changesCount, 1)

        let mobileKey = try await mobileArchive.read("/any/nfc/key.nfc")
        XCTAssertEqual(mobileKey, "two")

        let flipperKey = try await flipperArchive.read("/any/nfc/key_1.nfc")
        XCTAssertEqual(flipperKey, "one")

        let items = try await manifest.get().items
        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(items["/any/nfc/key.nfc"], Hash("two".md5))
        XCTAssertEqual(items["/any/nfc/key_1.nfc"], Hash("one".md5))
    }

    func testSyncShadow() async throws {
        let flipperArchive = InMemoryArchive()
        let mobileArchive = InMemoryArchive()
        let manifest = InMemoryManifest()

        try await mobileArchive.upsert("one", at: "/any/nfc/key.nfc")
        try await flipperArchive.upsert("one", at: "/any/nfc/key.nfc")

        try await mobileArchive.upsert("two", at: "/any/nfc/key.shd")
        try await flipperArchive.upsert("three", at: "/any/nfc/key.shd")

        try await manifest.upsert(.init([
            "/any/nfc/key.nfc": Hash("one".md5),
            "/any/nfc/key.shd": Hash("one".md5)
        ]))

        let archiveSync = ArchiveSync(
            flipperArchive: flipperArchive,
            mobileArchive: mobileArchive,
            syncedManifest: manifest)

        var progress: [Double] = []
        let changesCount = try await archiveSync.run {
            progress.append($0)
        }
        XCTAssertEqual(progress, [0.5, 1.0])
        XCTAssertEqual(changesCount, 1)

        let mobileKey = try await mobileArchive.read("/any/nfc/key.nfc")
        XCTAssertEqual(mobileKey, "one")
        let mobileShadow = try await mobileArchive.read("/any/nfc/key.shd")
        XCTAssertEqual(mobileShadow, "three")

        let items = try await manifest.get().items
        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(items["/any/nfc/key.nfc"], Hash("one".md5))
        XCTAssertEqual(items["/any/nfc/key.shd"], Hash("three".md5))
    }

    // NOTE: Flipper's filesystem is case-insensitive,
    // so we should delete the key first to handle renaming.
    // Using some amount of keys we hope to catch incorrect ordering
    // that can happen (e.g.) if we use Dictionary to store planned actions

    func testCaseChange() async throws {
        let flipperArchive = InMemoryArchive()
        let mobileArchive = InMemoryArchive()
        let manifest = InMemoryManifest()

        let iterations = 10

        var items: [Path: Hash] = .init()
        for i in 0..<iterations {
            try await flipperArchive.upsert("test", at: "/any/nfc/key\(i).nfc")
            try await mobileArchive.upsert("test", at: "/any/nfc/Key\(i).nfc")
            items["/any/nfc/key\(i).nfc"] = Hash("test".md5)
        }
        try await manifest.upsert(.init(items))

        let archiveSync = ArchiveSync(
            flipperArchive: flipperArchive,
            mobileArchive: mobileArchive,
            syncedManifest: manifest)

        var progress: [Double] = []
        let changesCount = try await archiveSync.run {
            progress.append($0)
        }

        XCTAssertEqual(progress.first ?? 0.0, 0.5, accuracy: 0.001)
        XCTAssertEqual(progress.last ?? 0.0, 1.0, accuracy: 0.001)
        XCTAssertEqual(changesCount, iterations * 2)

        for i in 0..<iterations {
            do {
                let key = try await flipperArchive.read("/any/nfc/Key\(i).nfc")
                XCTAssertEqual(key, "test")
            } catch {
                XCTFail("can't read /any/nfc/Key\(i).nfc")
            }
        }

        items = try await manifest.get().items
        XCTAssertEqual(items.count, iterations)
        for i in 0..<iterations {
            XCTAssertEqual(items["/any/nfc/Key\(i).nfc"], Hash("test".md5))
        }

        items = try await flipperArchive.getManifest().items
        XCTAssertEqual(items.count, iterations)
        for i in 0..<iterations {
            XCTAssertEqual(items["/any/nfc/Key\(i).nfc"], Hash("test".md5))
        }
    }

    func testBothDeleted() async throws {
        let flipperArchive = InMemoryArchive()
        let mobileArchive = InMemoryArchive()
        let manifest = InMemoryManifest()

        try await manifest.upsert(.init([
            "/any/nfc/key.nfc": Hash("content".md5)
        ]))

        let archiveSync = ArchiveSync(
            flipperArchive: flipperArchive,
            mobileArchive: mobileArchive,
            syncedManifest: manifest)

        var progress: [Double] = []
        let changesCount = try await archiveSync.run {
            progress.append($0)
        }
        XCTAssertEqual(progress, [0.5, 1.0])
        XCTAssertEqual(changesCount, 0)

        let items = try await manifest.get().items
        XCTAssertEqual(items.count, 0)
    }
}
