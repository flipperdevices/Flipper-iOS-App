class WantMoarAnalytics: Analytics {
    var analytics: [Analytics] = [
        CountlyAnalytics(),
        ClickhouseAnalytics()
    ]

    func record(_ event: Event) {
        analytics.forEach {
            $0.record(event)
        }
    }
}
