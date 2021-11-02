import Foundation

class FlipperSession: Session {
    let chunkedResponse: ChunkedResponse = .init()
    let sequencedResponse: SequencedResponse = .init()

    let sequencedRequest: SequencedRequest = .init()
    let chunkedRequest: ChunkedRequest = .init()

    var queue: [Command] = []

    struct Command {
        let id: Int
        let request: Request
        let continuation: Continuation
        let consumer: (Data) -> Void
    }

    var nextId = 1 {
        didSet {
            let commandIdSize = MemoryLayout.size(ofValue: PB_Main().commandID)
            let maxValue = Int(pow(2.0, Double(commandIdSize * 8)) - 1)
            if nextId >= maxValue {
                nextId = 1
            }
        }
    }

    func sendRequest(
        _ request: Request,
        continuation: @escaping Continuation,
        consumer: @escaping (Data) -> Void
    ) {
        queue.append(.init(
            id: nextId,
            request: request,
            continuation: continuation,
            consumer: consumer))

        nextId += 1

        if queue.count == 1 {
            sendNextRequest()
        }
    }

    func sendNextRequest() {
        guard let command = queue.first else { return }
        let requests = sequencedRequest.split(command.request)
        for var request in requests {
            request.commandID = .init(command.id)
            let chunks = chunkedRequest.split(request)
            for chunk in chunks {
                assert(!chunk.isEmpty)
                command.consumer(.init(chunk))
            }
        }
    }

    func didReceiveData(_ data: Data) {
        do {
            // single PB_Main can be split into ble chunks;
            // returns nil if data.count < main.size
            guard let nextResponse = try chunkedResponse.feed(data) else {
                return
            }
            guard let currentCommand = queue.first else {
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
            let command = queue.removeFirst()
            sendNextRequest()
            // handle current response
            command.continuation(result)
        } catch {
            print(error)
        }
    }
}
