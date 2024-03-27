import Combine
import Foundation

public class FlipperSession: Session {
    public static var current: FlipperSession?

    private let peripheral: BluetoothPeripheral
    private var subscriptions = [AnyCancellable]()

    let queue: Queue = .init()

    let messageStream: BroadcastStream<IncomingMessage> = .init()

    public var message: AsyncStream<IncomingMessage> {
        messageStream.subscribe()
    }

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

    public func send(_ message: OutgoingMessage) async throws {
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
                    logger.debug("< error(\(error))")
                    output.finish(throwing: error)
                }

                do {
                    for try await next in streams.input {
                        logger.debug("< response(\(next))")
                        input.yield(next)
                    }
                    input.finish()
                } catch {
                    logger.debug("< error(\(error))")
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
                if let message = try await queue.didReceiveData(data) {
                    onMessage(message)
                }
            } catch {
                logger.critical("\(error)")
            }
        }
    }

    func onMessage(_ message: IncomingMessage) {
        switch message {
        case .error(let error):
            logger.error("error message: \(error)")
        case .unknown(let command):
            logger.error("unknown command: \(command)")
        default:
            break
        }
        messageStream.yield(message)
    }
}
