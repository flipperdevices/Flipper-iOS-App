import Inject
import Peripheral

import Logging
import Combine
import Foundation

@MainActor
public class WidgetService: ObservableObject {
    @Published public var state: State = .idle
    @Published public var keys: [WidgetKey] = []
    @Published public var keyToEmulate: WidgetKey?

    @Published public var isExpanded = false

    public var isEmulating: Bool {
        state == .emulating
    }

    public var isError: Bool {
        switch state {
        case .error: return true
        default: return false
        }
    }

    public enum State: Equatable {
        case idle
        case loading
        case emulating
        case error(Error)

        public enum Error: Equatable {
            case appLocked
            case notSynced
            case cantConnect
            case bluetoothOff
        }
    }

    public func add(_ key: ArchiveItem) {
    }

    public func delete(at index: Int) {
    }

    func connect() {
    }

    func disconnect() {
    }

    func onFlipperStatusChanged(_ oldValue: FlipperState?) {
    }

    public func onSendPressed(for key: WidgetKey) {
    }

    public func onSendReleased(for key: WidgetKey) {
    }

    public func onEmulateTapped(for key: WidgetKey) {
    }

    func startEmulate(_ key: WidgetKey) {
    }

    func startEmulateOnConnect() {
    }

    func item(for key: WidgetKey) -> ArchiveItem? {
        nil
    }

    public func stopEmulate() {
    }

    func forceStopEmulate() {
    }

    func toggleEmulate(_ key: WidgetKey) {
    }

    func resetEmulate() {
    }
}

private extension Array where Element == ArchiveItem {
    func contains(widgetKey: WidgetKey) -> Bool {
        contains { $0.name == widgetKey.name && $0.kind == widgetKey.kind }
    }
}
