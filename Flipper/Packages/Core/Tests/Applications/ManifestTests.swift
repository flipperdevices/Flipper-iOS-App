import XCTest
import Foundation

@testable import Core

class ManifestTests: XCTestCase {
    var rawManifest: String = """
        Filetype: Flipper Application Installation Manifest
        Version: 1
        Full Name: Spectrum Analyzer
        Icon: iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAAAXNSR0IArs4c6QAA\
        AARzQklUCAgICHwIZIgAAAA4SURBVBiVnZAxCgBACMNS//9nHW4TlXIZS2hF8Uhu5EgAGY\
        YEwCSOC9+N672xSNkzXS0d6z0yZRXOlwwEaPtJ1wAAAABJRU5ErkJggg==
        Version Build API: 28.2
        UID: 64799d29f571401a6007823d
        Version UID: 6479fab100a677734210cf52
        Path: /ext/apps/Sub-GHz/spectrum_analyzer.fap

        """

    var iconData: Data {
        .init(base64Encoded: """
        iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAAAXNSR0IArs4c6QAA\
        AARzQklUCAgICHwIZIgAAAA4SURBVBiVnZAxCgBACMNS//9nHW4TlXIZS2hF8Uhu5EgAGY\
        YEwCSOC9+N672xSNkzXS0d6z0yZRXOlwwEaPtJ1wAAAABJRU5ErkJggg==
        """)!
    }

    func testDecoder() throws {
        let manifest = try FFFDecoder.decode(
            Applications.Manifest.self,
            from: rawManifest)

        XCTAssertEqual(
            manifest.fileType,
            "Flipper Application Installation Manifest"
        )

        XCTAssertEqual(manifest.version, "1")

        XCTAssertEqual(manifest.fullName, "Spectrum Analyzer")

        XCTAssertEqual(manifest.icon, iconData)

        XCTAssertEqual(manifest.buildAPI, "28.2")

        XCTAssertEqual(manifest.uid, "64799d29f571401a6007823d")

        XCTAssertEqual(manifest.versionUID, "6479fab100a677734210cf52")

        XCTAssertEqual(manifest.path, "/ext/apps/Sub-GHz/spectrum_analyzer.fap")
    }

    func testEncoder() throws {
        let manifest = Applications.Manifest(
            version: "1",
            fullName: "Spectrum Analyzer",
            icon: iconData,
            buildAPI: "28.2",
            uid: "64799d29f571401a6007823d",
            versionUID: "6479fab100a677734210cf52",
            path: "/ext/apps/Sub-GHz/spectrum_analyzer.fap")

        let result = try FFFEncoder.encode(manifest)

        XCTAssertEqual(result, rawManifest)
    }
}
