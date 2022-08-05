public protocol Analytics {
    func record(_ event: Event) async
}
