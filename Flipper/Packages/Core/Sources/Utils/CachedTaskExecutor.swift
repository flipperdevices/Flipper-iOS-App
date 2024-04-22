import Foundation

public actor CachedTaskExecutor<Key: Hashable, Value> {
    enum State {
        case ready(Value)
        case inProgress(Task<Value, Error>)
    }

    private var cache: [Key: State] = [:]
    private let dataSource: (Key) async throws -> Value

    public init(_ dataSource: @escaping (Key) async throws -> Value) {
        self.dataSource = dataSource
    }

    public func get(_ key: Key) async throws -> Value {
        if let current = cache[key] {
            switch current {
            case .ready(let data):
                return data
            case .inProgress(let task):
                return try await task.value
            }
        } else {
            let task = Task { try await dataSource(key) }
            cache[key] = .inProgress(task)

            do {
                let data = try await task.value
                cache[key] = .ready(data)
                return data
            } catch {
                logger.error("error on get by \(key)")
                cache[key] = nil
                throw error
            }
        }
    }
}

public class CachedNetworkLoader {
    public static let shared = CachedNetworkLoader()

    private let loader: CachedTaskExecutor<URL, Data>

    init() {
        self.loader = CachedTaskExecutor<URL, Data> { key in
            try await URLSession.shared.data(from: key).0
        }
    }

    public func get(_ url: URL) async throws -> Data {
        return try await loader.get(url)
    }
}
