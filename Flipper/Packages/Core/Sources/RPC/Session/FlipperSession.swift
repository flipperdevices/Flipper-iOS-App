import Foundation

class FlipperSession: Session {
    let peripheral: BluetoothPeripheral

    let chunkedInput: ChunkedInput = .init()
    let delimitedResponse: DelimitedResponse = .init()

    let delimitedRequest: DelimitedRequest = .init()
    var chunkedOutput: ChunkedOutput = .init()

    @CommandId var nextId: Int
    var queue: Queue = .init()
    var awaitingResponse: [Command] = []

    var onMessage: ((Message) -> Void)?

    var disposeBag = DisposeBag()

    init(peripheral: BluetoothPeripheral) {
        self.peripheral = peripheral
        subscribeToUpdates()
    }

    func subscribeToUpdates() {
        peripheral.received
            .sink { [weak self] in
                self?.didReceiveData($0)
            }
            .store(in: &disposeBag)

        peripheral.canWrite
            .sink { [weak self] in
                self?.onCanWrite()
            }
            .store(in: &disposeBag)
    }

    func send(
        _ message: Message,
        priority: Priority?
    ) async throws {
        _ = try await send(.message(message), id: 0, priority: priority)
    }

    func send(
        _ request: Request,
        priority: Priority? = nil
    ) async throws -> Response {
        try await send(.request(request), id: nextId, priority: priority)
    }

    private func send(
        _ content: Command.Content,
        id: Int,
        priority: Priority? = nil
    ) async throws -> Response {
        try await withUnsafeThrowingContinuation { continuation in
            let command = Command(
                id: id,
                content: content,
                continuation: continuation)

            queue.append(command, priority: priority)

            if awaitingResponse.isEmpty {
                sendNextCommand()
            }
        }
    }

    func sendNextCommand() {
        guard let command = queue.dequeue() else { return }
        switch command.content {
        case .message(let message):
            chunkedOutput.feed([message.serialize()])
            command.continuation.resume(returning: .ok)
            processChunkedOutput()
        case .request(let request):
            awaitingResponse.append(command)
            var requests = delimitedRequest.split(request)
            for index in requests.indices {
                requests[index].commandID = .init(command.id)
            }
            chunkedOutput.feed(requests)
            processChunkedOutput()
        }
    }

    func processChunkedOutput() {
        while chunkedOutput.hasData && peripheral.maximumWriteValueLength > 0 {
            let packetSize = peripheral.maximumWriteValueLength
            let next = chunkedOutput.next(maxSize: packetSize)
            peripheral.send(.init(next))
        }
    }
}

extension FlipperSession {
    func onCanWrite() {
        processChunkedOutput()
    }

    func didReceiveData(_ data: Data) {
        do {
            // single PB_Main can be split into ble chunks;
            // returns nil if data.count < main.size
            guard let nextCommand = try chunkedInput.feed(data) else {
                return
            }
            guard nextCommand.commandID != 0 else {
                onMessage?(.init(decoding: nextCommand))
                return
            }
            guard let currentCommand = awaitingResponse.first else {
                print("unexpected response", nextCommand)
                return
            }
            guard nextCommand.commandID == currentCommand.id else {
                print("invalid id \(nextCommand.commandID)")
                return
            }
            // complete PB_Main can be split into multiple messages
            guard let result = try delimitedResponse.feed(nextCommand) else {
                return
            }
            // dequeue and send next command
            let command = awaitingResponse.removeFirst()
            sendNextCommand()
            // handle current response
            switch result {
            case .success(let response):
                command.continuation.resume(returning: response)
            case .failure(let error):
                command.continuation.resume(throwing: error)
            }
        } catch {
            print(error)
        }
    }
}
