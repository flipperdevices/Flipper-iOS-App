import Combine
import Foundation
import Logging

class FlipperSession: Session {
    private let logger = Logger(label: "session")

    private let peripheral: BluetoothPeripheral
    private var subscriptions = [AnyCancellable]()

    let queue: Queue = .init()

    var onMessage: ((Message) -> Void)?
    var onError: ((Error) -> Void)?

    var timeoutTaskHandle: Task<(), Never>?

    init(peripheral: BluetoothPeripheral) {
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

    func send(_ message: Message) async throws {
        logger.debug(">> \(message)")
        for try await _ in await send(.message(message)).output { }
    }

    func send(_ request: Request) async -> AsyncThrowingStreams {
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
        await sendNextCommand()
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

    func close() async {
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
                    onMessage?(message)
                }
            } catch {
                logger.critical("\(error)")
            }
        }
    }
}

// MARK: Timeout

extension FlipperSession {
    var timeoutNanoseconds: UInt64 { 6 * 1_000 * 1_000_000 }

    func setupTimeoutTimer() {
        if let current = timeoutTaskHandle {
            current.cancel()
        }
        timeoutTaskHandle = Task {
            try? await Task.sleep(nanoseconds: timeoutNanoseconds)
            guard !Task.isCancelled else { return }
            guard self.peripheral.state == .connected else { return }
            guard await queue.isBusy else { return }
            self.logger.debug("time is out")
            Task { @MainActor in
                self.onError?(.timeout)
            }
        }
    }
}
