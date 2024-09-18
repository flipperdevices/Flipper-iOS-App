import SwiftUI
import WidgetKit

struct Entry: TimelineEntry {
    var date: Date
    let isEmulating: Bool
    let configuration: ConfigurationAppIntent
}
