import MFKey32v2

public enum ReaderAttack {
    public struct Result: Sendable {
        public let origin: ReaderLog.Line
        public let key: MFKey64?
    }

    public static func recoverKeys(from log: ReaderLog) -> AsyncStream<Result> {
        .init { continuation in
            Task {
                await withTaskGroup(of: Result.self) { group in
                    for line in log.lines {
                        group.addTask {
                            await recoverKey(from: line)
                        }
                    }
                    for await value in group {
                        continuation.yield(value)
                    }
                    continuation.finish()
                }
            }
        }
    }

    static func recoverKey(from line: ReaderLog.Line) async -> Result {
        await Task(priority: .background) {
            guard let key = MFKey32v2.recover(from: line.readerData) else {
                return .init(origin: line, key: nil)
            }
            return .init(origin: line, key: .init(value: key))
        }.value
    }
}
