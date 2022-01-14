import Foundation

class FlipperSession: Session {
    let peripheral: BluetoothPeripheral

    let chunkedResponse: ChunkedResponse = .init()
    let delimitedResponse: DelimitedResponse = .init()

    let delimitedRequest: DelimitedRequest = .init()
    var chunkedRequest: ChunkedRequest = .init()

    @CommandId var nextId: Int
    var queue: Queue = .init()
    var awaitingResponse: [Command] = []

    var onDecodeError: (() -> Void)?
    var onScreenFrame: ((ScreenFrame) -> Void)?

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

    func sendScreenFrame(_ frame: ScreenFrame) async throws {
        _ = try await send(.gui(.displayFrame(frame)), id: 0)
    }

    func send(
        _ request: Request,
        priority: Priority? = nil
    ) async throws -> Response {
        try await send(request, id: nextId, priority: priority)
    }

    func send(
        _ request: Request,
        id: Int,
        priority: Priority? = nil
    ) async throws -> Response {
        try await withUnsafeThrowingContinuation { continuation in
            let command = Command(
                id: id,
                request: request,
                continuation: continuation)

            queue.append(command, priority: priority)

            if awaitingResponse.isEmpty {
                sendNextRequest()
            }
        }
    }

    func sendNextRequest() {
        guard let command = queue.dequeue() else { return }
        if command.id != 0 {
            awaitingResponse.append(command)
        }
        var requests = delimitedRequest.split(command.request)
        for index in requests.indices {
            requests[index].commandID = .init(command.id)
        }
        chunkedRequest.feed(requests)
        processChunkedRequest()
        if command.id == 0 {
            command.continuation.resume(returning: .ok)
        }
    }

    func processChunkedRequest() {
        while chunkedRequest.hasData && peripheral.maximumWriteValueLength > 0 {
            let packetSize = peripheral.maximumWriteValueLength
            let next = chunkedRequest.next(maxSize: packetSize)
            peripheral.send(.init(next))
        }
    }

    func didReceiveUnbound(_ main: PB_Main) {
        guard main.commandStatus != .errorDecode else {
            onDecodeError?()
            return
        }
        guard case let .guiScreenFrame(content) = main.content else {
            return
        }
        guard let frame = ScreenFrame(.init(content.data)) else {
            return
        }
        onScreenFrame?(frame)
    }
}

extension FlipperSession {
    func onCanWrite() {
        processChunkedRequest()
    }

    func didReceiveData(_ data: Data) {
        do {
            // single PB_Main can be split into ble chunks;
            // returns nil if data.count < main.size
            guard let nextResponse = try chunkedResponse.feed(data) else {
                return
            }
            guard nextResponse.commandID != 0 else {
                didReceiveUnbound(nextResponse)
                return
            }
            guard let currentCommand = awaitingResponse.first else {
                print("unexpected response", nextResponse)
                return
            }
            guard nextResponse.commandID == currentCommand.id else {
                print("invalid id \(nextResponse.commandID)")
                return
            }
            // complete PB_Main can be split into multiple messages
            guard let result = try delimitedResponse.feed(nextResponse) else {
                return
            }
            // dequeue and send next command
            let command = awaitingResponse.removeFirst()
            sendNextRequest()
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
