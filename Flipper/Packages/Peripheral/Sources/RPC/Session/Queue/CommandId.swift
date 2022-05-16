import func Foundation.pow

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
