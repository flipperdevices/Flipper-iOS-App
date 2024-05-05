actor SerialTaskQueue {
    var taskQueue: [() async -> Void] = []

    func enqueue(_ task: @escaping () async -> Void) async {
        taskQueue.append(task)
        if taskQueue.count == 1 {
            await processQueue()
        }
    }

    private func processQueue() async {
        while let next = taskQueue.first {
            await next()
            taskQueue.removeFirst()
        }
    }
}
