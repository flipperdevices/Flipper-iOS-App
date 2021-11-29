import func Foundation.pow

extension FlipperSession {
    struct Command {
        let id: Int
        let request: Request
        let continuation: UnsafeContinuation<Response, Swift.Error>
    }

    struct Queue {
        private var normal: [Command] = []
        private var background: [Command] = []

        private var processing: [Command] = []

        var count: Int { normal.count + background.count }

        mutating func append(_ command: Command, priority: Priority?) {
            switch priority {
            case .none: normal.append(command)
            case .background: background.append(command)
            }
        }

        mutating func dequeue() -> Command? {
            if !normal.isEmpty { return normal.removeFirst() }
            if !background.isEmpty { return background.removeFirst() }
            return nil
        }
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
