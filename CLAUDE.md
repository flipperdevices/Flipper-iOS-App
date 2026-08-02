# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

Flipper-iOS-App is the iOS companion app for the Flipper Zero device family ("Mobile app to rule all the Flipper's family"). It talks to a physical Flipper device over Bluetooth, manages its file archive (NFC/RFID/Infrared/iButton/Sub-GHz keys), and integrates with the Flipper cloud catalog/backend.

## Build & test commands

The Xcode project lives at `Flipper/Flipper.xcodeproj`, scheme `Flipper(iOS)`. There is no fastlane/CI build pipeline in this repo — builds and tests are run through Xcode or `xcodebuild` directly.

```bash
# Build the app
xcodebuild -project Flipper/Flipper.xcodeproj -scheme "Flipper(iOS)" -destination "platform=iOS Simulator,name=iPhone 17 Pro" build

# Lint (SwiftLint, config at Flipper/.swiftlint.yml)
cd Flipper && ./perform_lint.sh
# or directly:
cd Flipper && ./swiftlint
```

Each feature/domain package under `Flipper/Packages/*` is an independent Swift Package with its own `Tests/` directory, so tests can be run per-package without opening the full app:

```bash
# Run all tests for one package
cd Flipper/Packages/Core && swift test

# Run a single test (XCTest selector syntax)
cd Flipper/Packages/Core && swift test --filter ArchiveTests/testSomething
```

This repo has `.mcp.json` configured for XcodeBuildMCP and `.xcodebuildmcp/config.yaml` with a default session profile (`ios`) pointed at the `Flipper(iOS)` scheme — prefer the XcodeBuildMCP tools over raw `xcodebuild` invocations when available.

## Code style

- Line length limit is 80 characters (enforced by both `.editorconfig` and SwiftLint `line_length`).
- SwiftLint disables `todo`, `nesting`, `opening_brace`, `identifier_name`, `cyclomatic_complexity`, `void_function_in_ternary` — don't fight these where they'd normally fire.
- `Packages/Peripheral` and parts of `Packages/Core` (protobuf-generated sources, the `Version` utils) are excluded from lint — don't expect clean lint output there and don't try to "fix" generated code style.

## Architecture

The codebase is split between the iOS app target (`Flipper/iOS`, `Flipper/AppIntents`, `Flipper/Shared`, `Flipper/ActivityWidget`, `Flipper/LiveWidget`, `Flipper/KeyPreview`) and a set of local Swift Packages under `Flipper/Packages/` that contain essentially all business logic. The app target is thin — it composes SwiftUI screens (`Flipper/iOS/UI/{Apps,Archive,Device,Hub,Infrared,Main,Options,RemoteControl,TabView,Welcome,...}`) on top of these packages, plus App Intents/Shortcuts support (`Flipper/AppIntents`) and widgets (`ActivityWidget`, `LiveWidget`).

Package dependency graph (leaf → root):

- **Macro** — standalone Swift macro plugin (`SwiftSyntax`-based), depended on by `Backend` and `Core` for compile-time code generation.
- **Peripheral** — lowest-level layer: Bluetooth transport and the RPC/protobuf protocol spoken with the physical Flipper device (`Sources/Bluetooth`, `Sources/RPC/{Model,Protobuf,Session}`). No dependency on other local packages.
- **Analytics** — event tracking abstraction with backends for Countly, Clickhouse, and "WantMoar", plus its own protobuf event schema.
- **Activity** — Live Activity / progress UI support, consumed by `Core`.
- **MFKey32v2** — a C library (`CCrapto1`) wrapped in Swift for Mifare Classic key-recovery ("reader attack") functionality.
- **Backend** — networking clients for the Flipper cloud services: `Catalog` (app/firmware catalog) and `Infrared` (IR signal database), built on `Macro`.
- **Core** — the app's domain layer; depends on all of the above (`Macro`, `Analytics`, `Activity`, `Peripheral`, `MFKey32v2`, `Backend`). Owns device pairing (`PairedDevice`), the local file archive and its favorites/manifest handling (`Archive`), sharing/deep-link encoding (`Sharing`), OTA firmware updates (`Update`), region/provisioning data (`Provisioning`), the reader-attack flow (`ReaderAttack`), and the high-level `Flipper` service that apps/UI code talk to.
- **Notifications** — push notifications via Firebase Cloud Messaging; kept separate from `Core` since it pulls in the Firebase SDK.

When changing device-communication behavior, start in `Peripheral` (transport/protocol) vs. `Core/Sources/Flipper` (device service facade) depending on whether the change is protocol-level or app-facing. When changing anything catalog/IR-database related, that's `Backend`, not `Core`.

`Core`, `Backend`, `Peripheral`, and `Analytics` all declare `swift-protobuf` dependencies and carry generated `Protobuf` sources — treat files under any `Sources/**/Protobuf` or `Sources/**/events` directory as generated, not hand-written.
