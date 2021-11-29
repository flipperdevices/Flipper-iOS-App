import Foundation

class FlipperSession: Session {
    let peripheral: BluetoothPeripheral

    let chunkedResponse: ChunkedResponse = .init()
    let sequencedResponse: SequencedResponse = .init()

    let sequencedRequest: SequencedRequest = .init()
    var chunkedRequest: ChunkedRequest = .init()

    @CommandId var nextId: Int
    var queue: Queue = .init()
    var awaitingResponse: [Command] = []

    var onScreenFrame: ((ScreenFrame) -> Void)?

    init(peripheral: BluetoothPeripheral) {
        self.peripheral = peripheral
        self.peripheral.delegate = self
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
        var requests = sequencedRequest.split(command.request)
        for index in requests.indices {
            requests[index].commandID = .init(command.id)
        }
        chunkedRequest.feed(requests)
        processChunkedRequest()
    }

    func processChunkedRequest() {
        while chunkedRequest.canWrite {
            let next = chunkedRequest.next()
            peripheral.send(.init(next))
        }
    }

    func didReceiveUnbound(_ main: PB_Main) {
        onScreenFrame?(.init(main))
    }
}

// MARK: PeripheralDelegate

extension FlipperSession: PeripheralDelegate {
    func send(_ data: Data) {
        peripheral.send(data)
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
            guard let result = try sequencedResponse.feed(nextResponse) else {
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

    func didReceiveFlowControl(freeSpace data: Data, packetSize: Int) {
        let freeSpace = data.withUnsafeBytes {
            $0.load(as: Int32.self).bigEndian
        }
        chunkedRequest.didReceiveFlowControl(
            freeSpace: Int(freeSpace),
            packetSize: packetSize)
        processChunkedRequest()
    }
}
