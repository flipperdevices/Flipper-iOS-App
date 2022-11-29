import Inject
import Combine
import Logging
import struct Foundation.Date

public class BluetoothRPC: RPC {
    private let logger = Logger(label: "rpc")

    @Inject private var connector: BluetoothConnector
    private var connectorHandle: AnyCancellable?
    private var peripheralHandle: AnyCancellable?

    public var session: Session?
    private var peripheral: BluetoothPeripheral? {
        didSet { self.peripheralDidChange() }
    }
    private var onScreenFrame: ((ScreenFrame) -> Void)?
    private var onAppStateChanged: ((Message.AppState) -> Void)?

    // TODO: send as single packet
    private var pressButtonInProgress = false

    init() {
        connectorHandle = connector.connected
            .map { $0.first }
            .assign(to: \.peripheral, on: self)
    }

    private func peripheralDidChange() {
        peripheralHandle = peripheral?.info
            .sink { [weak self] in
                guard let self else { return }
                Task { await self.updateSession() }
            }
    }

    private func updateSession() async {
        guard let peripheral = peripheral, peripheral.state == .connected else {
            await session?.close()
            session = nil
            return
        }
        guard session == nil else { return }
        self.session = FlipperSession(peripheral: peripheral)
        self.session?.onMessage = self.onMessage
        self.session?.onError = self.onError
    }

    private func onMessage(_ message: Message) {
        switch message {
        case .error(let error):
            onError(error)
        case .screenFrame(let screenFrame):
            onScreenFrame?(screenFrame)
        case .appState(let state):
            onAppStateChanged?(state)
        case .unknown(let command):
            logger.error("unknown command: \(command)")
        default:
            logger.error("unhandled message: \(message)")
        }
    }

    private func onError(_ error: Error) {
        logger.error("\(error)")
        reconnect()
    }

    private func reconnect() {
        if let peripheral = peripheral {
            connector.disconnect(from: peripheral.id)
            connector.connect(to: peripheral.id)
        }
    }
}

// MARK: Public methods

extension BluetoothRPC {
    public func deviceInfo(
    ) -> AsyncThrowingStream<(String, String), Swift.Error> {
        .init { continuation in
            Task {
                do {
                    guard let session = session else {
                        throw Error.unsupported(0)
                    }
                    let streams = await session.send(.system(.deviceInfo))
                    for try await next in streams.input {
                        guard case let .system(.deviceInfo(key, value)) = next else {
                            throw Error.unexpectedResponse(next)
                        }
                        continuation.yield((key, value))
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    public func powerInfo(
    ) -> AsyncThrowingStream<(String, String), Swift.Error> {
        .init { continuation in
            Task {
                do {
                    guard let session = session else {
                        throw Error.unsupported(0)
                    }
                    let streams = await session.send(.system(.powerInfo))
                    for try await next in streams.input {
                        guard case let .system(.powerInfo(key, value)) = next else {
                            throw Error.unexpectedResponse(next)
                        }
                        continuation.yield((key, value))
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    @discardableResult
    public func ping(_ bytes: [UInt8]) async throws -> [UInt8] {
        let response = try await session?
            .send(.system(.ping(bytes)))
            .response
        guard case .system(.ping(let result)) = response else {
            throw Error.unexpectedResponse(response)
        }
        return result
    }

    public func reboot(to mode: Message.RebootMode) async throws {
        try await session?.send(.reboot(mode))
    }

    public func getDate() async throws -> Date {
        let response = try await session?
            .send(.system(.getDate))
            .response
        guard case .system(.dateTime(let result)) = response else {
            throw Error.unexpectedResponse(response)
        }
        return result
    }

    public func setDate(_ date: Date) async throws {
        let response = try await session?
            .send(.system(.setDate(date)))
            .response
        guard case .ok = response else {
            throw Error.unexpectedResponse(response)
        }
    }

    public func update(manifest: Path) async throws {
        let response = try await session?
            .send(.system(.update(manifest)))
            .response
        switch response {
        case .ok: break
        case .system(.update(.ok)): break
        default: throw Error.unexpectedResponse(response)
        }
    }

    public func getStorageInfo(at path: Path) async throws -> StorageSpace {
        let response = try await session?
            .send(.storage(.info(path)))
            .response
        guard case .storage(.info(let result)) = response else {
            throw Error.unexpectedResponse(response)
        }
        return result
    }

    public func listDirectory(at path: Path) async throws -> [Element] {
        let response = try await session?
            .send(.storage(.list(path)))
            .response
        guard case .storage(.list(let items)) = response else {
            throw Error.unexpectedResponse(response)
        }
        return items.filter { !$0.name.isEmpty }
    }

    public func getSize(at path: Path) async throws -> Int {
        let response = try await session?
            .send(.storage(.stat(path)))
            .response
        guard case .storage(.stat(let size)) = response else {
            throw Error.unexpectedResponse(response)
        }
        return size
    }

    public func getTimestamp(at path: Path) async throws -> Date {
        let response = try await session?
            .send(.storage(.timestamp(path)))
            .response
        guard case .storage(.timestamp(let timestamp)) = response else {
            throw Error.unexpectedResponse(response)
        }
        return timestamp
    }

    public func createFile(at path: Path, isDirectory: Bool) async throws {
        let response = try await session?
            .send(.storage(.create(path, isDirectory: isDirectory)))
            .response
        guard case .ok = response else {
            throw Error.unexpectedResponse(response)
        }
    }

    public func deleteFile(at path: Path, force: Bool) async throws {
        let response = try await session?
            .send(.storage(.delete(path, isForce: force)))
            .response
        guard case .ok = response else {
            throw Error.unexpectedResponse(response)
        }
    }

    public func readFile(
        at path: Path
    ) -> AsyncThrowingStream<[UInt8], Swift.Error> {
        .init { continuation in
            Task {
                do {
                    guard let session = session else {
                        throw Error.unsupported(0)
                    }
                    let streams = await session.send(.storage(.read(path)))
                    for try await next in streams.input {
                        guard case .storage(.file(let bytes)) = next else {
                            throw Error.unexpectedResponse(next)
                        }
                        continuation.yield(bytes)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    public func writeFile(
        at path: Path,
        bytes: [UInt8]
    ) -> AsyncThrowingStream<Int, Swift.Error> {
        .init { continuation in
            Task {
                do {
                    guard let session = session else {
                        throw Error.unsupported(0)
                    }
                    let streams = await session.send(.storage(.write(path, bytes)))
                    for try await next in streams.output {
                        guard case let .request(.storage(.write(_, chunk))) = next else {
                            continuation.finish(throwing: Error.unexpectedRequest)
                            return
                        }
                        continuation.yield(chunk.count)
                    }
                    for try await next in streams.input {
                        guard case .ok = next else {
                            continuation.finish(throwing: Error.unexpectedResponse(next))
                            return
                        }
                        continuation.finish()
                        return
                    }
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    public func moveFile(from: Path, to: Path) async throws {
        let response = try await session?
            .send(.storage(.move(from, to)))
            .response
        guard case .ok = response else {
            throw Error.unexpectedResponse(response)
        }
    }

    public func calculateFileHash(at path: Path) async throws -> Hash {
        let response = try await session?
            .send(.storage(.hash(path)))
            .response
        guard case .storage(.hash(let bytes)) = response else {
            throw Error.unexpectedResponse(response)
        }
        return .init(bytes)
    }

    public func appStart(_ name: String, args: String) async throws {
        let response = try await session?
            .send(.application(.start(name, args)))
            .response
        guard case .ok = response else {
            throw Error.unexpectedResponse(response)
        }
    }

    public func appLoadFile(_ path: Path) async throws {
        let response = try await session?
            .send(.application(.loadFile(path)))
            .response
        guard case .ok = response else {
            throw Error.unexpectedResponse(response)
        }
    }

    public func appButtonPress(_ button: String) async throws {
        let response = try await session?
            .send(.application(.pressButton(button)))
            .response
        guard case .ok = response else {
            throw Error.unexpectedResponse(response)
        }
    }

    public func appButtonRelease() async throws {
        let response = try await session?
            .send(.application(.releaseButton))
            .response
        guard case .ok = response else {
            throw Error.unexpectedResponse(response)
        }
    }

    public func appExit() async throws {
        let response = try await session?
            .send(.application(.exit))
            .response
        guard case .ok = response else {
            throw Error.unexpectedResponse(response)
        }
    }

    public func startStreaming() async throws {
        let response = try await session?
            .send(.gui(.screenStream(true)))
            .response
        guard case .ok = response else {
            throw Error.unexpectedResponse(response)
        }
    }

    public func stopStreaming() async throws {
        let response = try await session?
            .send(.gui(.screenStream(false)))
            .response
        guard case .ok = response else {
            throw Error.unexpectedResponse(response)
        }
    }

    public func onScreenFrame(_ body: @escaping (ScreenFrame) -> Void) {
        self.onScreenFrame = body
    }

    public func onAppStateChanged(_ body: @escaping (Message.AppState) -> Void) {
        self.onAppStateChanged = body
    }

    public func pressButton(_ button: InputKey) async throws {
        guard !pressButtonInProgress else { return }
        pressButtonInProgress = true
        defer { pressButtonInProgress = false }

        func send(_ type: InputType) async throws -> Response? {
            try await session?.send(.gui(.button(button, type))).response
        }
        guard try await send(.press) == .ok else {
            logger.error("sending press type failed")
            return
        }
        guard try await send(.short) == .ok else {
            logger.error("sending short type failed")
            return
        }
        guard try await send(.release) == .ok else {
            logger.error("sending release type failed")
            return
        }
    }

    public func playAlert() async throws {
        let response = try await session?
            .send(.system(.alert))
            .response
        guard case .ok = response else {
            throw Error.unexpectedResponse(response)
        }
    }

    public func startVirtualDisplay(with frame: ScreenFrame?) async throws {
        let response = try await session?
            .send(.gui(.virtualDisplay(true, frame)))
            .response
        guard case .ok = response else {
            throw Error.unexpectedResponse(response)
        }
    }

    public func stopVirtualDisplay() async throws {
        let response = try await session?
            .send(.gui(.virtualDisplay(false, nil)))
            .response
        guard case .ok = response else {
            throw Error.unexpectedResponse(response)
        }
    }

    public func sendScreenFrame(_ frame: ScreenFrame) async throws {
        try await session?.send(.screenFrame(frame))
    }
}
