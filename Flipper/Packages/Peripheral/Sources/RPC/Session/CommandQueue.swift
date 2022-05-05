import func Foundation.pow

// swiftlint:disable nesting

extension FlipperSession {
    struct Command {
        let id: Int
        let content: Content
        let continuation: UnsafeContinuation<Response, Swift.Error>

        enum Content {
            case request(Request)
            case message(Message)
        }
    }

    struct Queue {
        private var commands: [Command] = []

        var count: Int { commands.count }

        mutating func append(_ command: Command) {
            commands.append(command)
        }

        mutating func dequeue() -> Command? {
            guard !commands.isEmpty else { return nil }
            return commands.removeFirst()
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
