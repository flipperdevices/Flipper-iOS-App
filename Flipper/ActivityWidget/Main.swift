import WidgetKit
import SwiftUI

@main
struct ActivityWidgetBundle: WidgetBundle {
    var body: some Widget {
        if #available(iOSApplicationExtension 16.2, *) {
            LiveActivity()
        }
    }
}
