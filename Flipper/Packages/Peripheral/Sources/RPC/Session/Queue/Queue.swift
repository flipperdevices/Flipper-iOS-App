import struct Foundation.Data

actor Queue {
    @CommandId var nextId: Int
    private var commands: [Command] = []
    private var tail: [UInt8] = []
    let chunkedInput: ChunkedInput = .init()
    var chunkedOutput: ChunkedOutput = .init()

    var onResponse: [Int: InputContinuation] = [:]

    var isBusy: Bool { !onResponse.isEmpty }

    var count: Int { commands.count }
    var isEmpty: Bool { commands.isEmpty && tail.isEmpty }

    func feed(_ content: Content) -> AsyncThrowingStreams {
        .init { output, input in
            commands.append(.init(
                id: nextId,
                content: content,
                outputContinuation: output,
                inputContinuation: input))
        }
    }

    func drain(upTo limit: Int) -> [UInt8] {
        var result: [UInt8] = []
        while result.count < limit {
            guard chunkedOutput.isEmpty else {
                result += chunkedOutput.drain(upTo: limit - result.count)
                continue
            }
            guard !commands.isEmpty else {
                return result
            }
            if commands[0].id != 0 {
                onResponse[commands[0].id] = commands[0].inputContinuation
            }
            guard let nextContent = commands[0].delimited.drain() else {
                commands[0].outputContinuation.finish()
                commands.removeFirst()
                continue
            }
            var nextMain = nextContent.serialize()
            nextMain.commandID = .init(commands[0].id)
            if !commands[0].delimited.isEmpty {
                nextMain.hasNext_p = true
            }
            chunkedOutput.feed(nextMain)
            commands[0].outputContinuation.yield(nextContent)
        }
        return result
    }

    func didReceiveData(_ data: Data) throws -> Message? {
        // single PB_Main can be split into ble chunks;
        // returns nil if data.count < main.size
        guard let nextMain = try chunkedInput.feed(data) else {
            return nil
        }
        guard nextMain.commandID != 0 else {
            return .init(decoding: nextMain)
        }

        let commandId = Int(nextMain.commandID)
        guard let continuation = onResponse[commandId] else {
            throw Error.unexpectedResponse(try? Response(decoding: nextMain))
        }

        do {
            let response = try Response(decoding: nextMain)
            continuation.yield(response)
            if !nextMain.hasNext_p {
                continuation.finish()
                onResponse[commandId] = nil
            }
        } catch {
            continuation.finish(throwing: error)
            onResponse[commandId] = nil
        }
        return nil
    }

    func cancel() {
        for command in self.commands {
            command.inputContinuation.finish(throwing: Error.canceled)
            command.outputContinuation.finish(throwing: Error.canceled)
        }
        commands.removeAll()

        for continuation in onResponse.values {
            continuation.finish(throwing: Error.canceled)
        }
        onResponse.removeAll()
    }
}
