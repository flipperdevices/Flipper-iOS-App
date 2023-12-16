import Dispatch

class SyncTask<T> {
    let semaphore = DispatchSemaphore(value: 0)
    private var result: T?
    init(_ task: @escaping () async -> T) {
        Task {
            result = await task()
            semaphore.signal()
        }
    }

    func get() -> T {
        semaphore.wait()
        return result!
    }
}
