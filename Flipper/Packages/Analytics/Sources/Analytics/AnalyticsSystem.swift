public actor AnalyticsSystem {
    static var handler: EventHandler?

    static var error: String {
        "analytics system can only be initialized once per process."
    }

    public static func bootstrap(_ handlers: [EventHandler]) {
        precondition(self.handler == nil, error)
        self.handler = WantMoarEventHandler(handlers: handlers)
    }

    static func bootstrapInternal(_ handler: EventHandler) {
        self.handler = handler
    }
}
