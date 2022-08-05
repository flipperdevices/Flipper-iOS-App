import Countly

actor CountlyAnalytics: Analytics {
    init() {
        let config = CountlyConfig()
        config.appKey = "COUNTLY_APP_KEY"
        config.host = "https://countly.flipp.dev/"
        Countly.sharedInstance().start(with: config)
    }

    func record(_ event: Event) async {
        Countly.sharedInstance().recordEvent(event.key)
    }
}
