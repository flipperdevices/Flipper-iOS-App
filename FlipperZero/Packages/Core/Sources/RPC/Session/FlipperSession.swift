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

    func send(
        _ request: Request,
        priority: Priority? = nil
    ) async throws -> Response {
        return try await withUnsafeThrowingContinuation { continuation in
            let command = Command(
                id: nextId,
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
        awaitingResponse.append(command)
        var requests = delimitedRequest.split(command.request)
        for index in requests.indices {
            requests[index].commandID = .init(command.id)
        }
        chunkedRequest.feed(requests)
        processChunkedRequest()
    }

    func processChunkedRequest() {
        while chunkedRequest.hasData && peripheral.maximumWriteValueLength > 0 {
            let packetSize = peripheral.maximumWriteValueLength
            let next = chunkedRequest.next(maxSize: packetSize)
            peripheral.send(.init(next))
        }
    }

    func didReceiveUnbound(_ main: PB_Main) {
        onScreenFrame?(.init(main))
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
