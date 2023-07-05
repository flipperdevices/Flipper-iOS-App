public actor Debouncer {
    private let milliseconds: Int
    private var task: Task<Void, Swift.Error>?

    public init(milliseconds: Int) {
        self.milliseconds = milliseconds
    }

    public init(seconds: Int) {
        self.init(milliseconds: seconds * 1000)
    }

    public func submit(_ body: @escaping () async throws -> Void) rethrows {
        cancel()
        task = Task {
            try await Task.sleep(milliseconds: milliseconds)
            try await body()
        }
    }

    public func cancel() {
        task?.cancel()
    }
}
