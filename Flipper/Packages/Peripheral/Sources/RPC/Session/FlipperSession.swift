import Combine
import Foundation

public class FlipperSession: Session {
    public static var current: FlipperSession?

    private let peripheral: BluetoothPeripheral
    private var subscriptions = [AnyCancellable]()

    let queue: Queue = .init()

    public var onMessage: ((Message) -> Void)?
    public var onError: ((Error) -> Void)?

    public var onScreenFrame: ((ScreenFrame) -> Void)?
    public var onAppStateChanged: ((Message.AppState) -> Void)?

    var timeoutTask: Task<Void, Swift.Error>?

    public init(peripheral: BluetoothPeripheral) {
        logger.info("session started")
        self.peripheral = peripheral
        subscribeToUpdates()
    }

    func subscribeToUpdates() {
        peripheral.received
            .sink { [weak self] in
                self?.didReceiveData($0)
            }
            .store(in: &subscriptions)

        peripheral.canWrite
            .sink { [weak self] in
                self?.onCanWrite()
            }
            .store(in: &subscriptions)
    }

    public func send(_ message: Message) async throws {
        logger.debug(">> \(message)")
        for try await _ in await send(.message(message)).output { }
    }

    public func send(_ request: Request) async -> AsyncThrowingStreams {
        .init { output, input in
            Task {
                let streams = await send(.request(request))

                do {
                    for try await next in streams.output {
                        logger.debug("> \(next)")
                        output.yield(next)
                    }
                    output.finish()
                } catch {
                    output.finish(throwing: error)
                }

                do {
                    for try await next in streams.input {
                        logger.debug("< response(\(next))")
                        input.yield(next)
                    }
                    input.finish()
                } catch {
                    input.finish(throwing: error)
                }
            }
        }
    }

    private func send(_ content: Content) async -> AsyncThrowingStreams {
        let streams = await queue.feed(content)
        if await queue.count == 1 {
            await sendNextCommand()
        }
        return streams
    }

    func sendNextCommand() async {
        while !(await queue.isEmpty) && peripheral.maximumWriteValueLength > 0 {
            let size = peripheral.maximumWriteValueLength
            let next = await queue.drain(upTo: size)
            peripheral.send(.init(next))
            setupTimeoutTimer()
        }
    }

    public func close() async {
        logger.info("canceling tasks...")
        await queue.cancel()
        logger.info("canceling tasks done")
    }
}

extension FlipperSession {
    func onCanWrite() {
        Task {
            await sendNextCommand()
        }
    }

    func didReceiveData(_ data: Data) {
        Task {
            do {
                setupTimeoutTimer()
                if let message = try await queue.didReceiveData(data) {
                    onMessage(message)
                }
            } catch {
                logger.critical("\(error)")
            }
        }
    }

    func onMessage(_ message: Message) {
        switch message {
        case .error(let error):
            logger.error("error message: \(error)")
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
}

// MARK: Timeout

extension FlipperSession {
    var timeoutNanoseconds: UInt64 { 30 * 1_000 * 1_000_000 }

    func setupTimeoutTimer() {
        if let current = timeoutTask {
            current.cancel()
        }
        timeoutTask = Task {
            try await Task.sleep(nanoseconds: timeoutNanoseconds)
            guard self.peripheral.state == .connected else { return }
            guard await queue.isBusy else { return }
            logger.debug("time is out")
            Task { @MainActor in
                self.onError?(.timeout)
            }
        }
    }
}
