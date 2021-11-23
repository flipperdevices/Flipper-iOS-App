import Foundation

class FlipperSession: Session {
    let chunkedResponse: ChunkedResponse = .init()
    let sequencedResponse: SequencedResponse = .init()

    let sequencedRequest: SequencedRequest = .init()
    var chunkedRequest: ChunkedRequest = .init()

    weak var outputDelegate: PeripheralOutputDelegate? {
        get { chunkedRequest.delegate }
        set { chunkedRequest.delegate = newValue }
    }

    weak var inputDelegate: PeripheralInputDelegate?

    @CommandId var nextId: Int
    var queue: Queue = .init()
    var awaitingResponse: [Command] = []

    struct Queue {
        private var queue: [Command] = []
        private var backgroundQueue: [Command] = []

        var count: Int { queue.count + backgroundQueue.count }

        mutating func append(_ command: Command, priority: Priority?) {
            switch priority {
            case .none: queue.append(command)
            case .background: backgroundQueue.append(command)
            }
        }

        mutating func dequeue() -> Command? {
            if !queue.isEmpty { return queue.removeFirst() }
            if !backgroundQueue.isEmpty { return backgroundQueue.removeFirst() }
            return nil
        }
    }

    struct Command {
        let id: Int
        let request: Request
        let continuation: Continuation
    }

    func sendRequest(
        _ request: Request,
        priority: Priority? = nil,
        continuation: @escaping Continuation
    ) {
        let command = Command(
            id: nextId,
            request: request,
            continuation: continuation
        )

        queue.append(command, priority: priority)

        if awaitingResponse.isEmpty {
            sendNextRequest()
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
            command.continuation(result)
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
    }

    func didReceiveUnbound(_ main: PB_Main) {
        let frame = ScreenFrame(main)
        inputDelegate?.onScreenFrame(frame)
    }
}

@propertyWrapper
struct CommandId {
    private var nextId = 1

    let maxId: Int = {
        let commandIdSize = MemoryLayout.size(ofValue: PB_Main().commandID)
        return Int(pow(2.0, Double(commandIdSize * 8)) - 1)
    }()

    var wrappedValue: Int {
        mutating get {
            defer {
                nextId += 1
                if nextId >= maxId {
                    nextId = 1
                }
            }
            return nextId
        }
    }
}
