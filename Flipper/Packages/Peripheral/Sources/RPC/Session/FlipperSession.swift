import Combine
import Foundation
import Logging

class FlipperSession: Session {
    private let logger = Logger(label: "session")

    private let peripheral: BluetoothPeripheral
    private var subscriptions = [AnyCancellable]()

    var queue: Queue = .init()

    var onMessage: ((Message) -> Void)?
    var onError: ((Error) -> Void)?

    var timeoutTimer: Timer?

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
        for try await _ in send(.message(message)).output { }
    }

    func send(_ request: Request) -> AsyncThrowingStreams {
        return .init { output, input in
            let streams = send(.request(request))

            Task {
                do {
                    for try await next in streams.output {
                        logger.debug("> \(next)")
                        output.yield(next)
                    }
                    output.finish()
                } catch {
                    output.finish(throwing: error)
                }
            }

            Task {
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

    private func send(_ content: Content) -> AsyncThrowingStreams {
        defer { sendNextCommand() }
        return queue.feed(content)
    }

    func sendNextCommand() {
        while !queue.isEmpty && peripheral.maximumWriteValueLength > 0 {
            let size = peripheral.maximumWriteValueLength
            let next = queue.drain(upTo: size)
            peripheral.send(.init(next))
            setupTimeoutTimer()
        }
    }

    func close() {
        logger.info("canceling tasks...")
        queue.cancel()
        logger.info("canceling tasks done")
    }
}

extension FlipperSession {
    func onCanWrite() {
        sendNextCommand()
    }

    func didReceiveData(_ data: Data) {
        do {
            setupTimeoutTimer()
            if let message = try queue.didReceiveData(data) {
                onMessage?(message)
            }
        } catch {
            logger.critical("\(error)")
        }
    }
}

// MARK: Timeout

extension FlipperSession {
    var timeout: Double { 6 }

    func setupTimeoutTimer() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let timeoutTimer = self.timeoutTimer {
                timeoutTimer.invalidate()
            }
            self.timeoutTimer = .scheduledTimer(
                withTimeInterval: self.timeout,
                repeats: false
            ) { [weak self] _ in
                guard let self = self else { return }
                guard self.peripheral.state == .connected else { return }
                guard self.queue.onResponse.isEmpty == false else { return }
                self.logger.debug("time is out")
                self.onError?(.timeout)
            }
        }
    }
}
