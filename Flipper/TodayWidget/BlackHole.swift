import NotificationCenter

// NOTE: hold all the warnings here

typealias WidgetProviding = NCWidgetProviding
typealias WidgetDisplayMode = NCWidgetDisplayMode
typealias UpdateResult = NCUpdateResult

extension NSExtensionContext {
    public final var widgetAvailableDisplayMode: NCWidgetDisplayMode {
        get { widgetLargestAvailableDisplayMode }
        set { widgetLargestAvailableDisplayMode = newValue }
    }
}
