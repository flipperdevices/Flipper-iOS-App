import Core

import SwiftUI
import NotificationCenter

public struct WidgetView: View {
    @EnvironmentObject var widget: TodayWidget

    public init() {
    }

    public var body: some View {
        VStack(spacing: 0) {
            Divider()
                .foregroundColor(.black4)

            if let error = widget.error {
                WidgetError(error) {
                    widget.error = nil
                }
                .padding(.vertical, 14)
            } else {
                WidgetKeysView(
                    keys: widget.keys,
                    isExpanded: widget.isExpanded
                )
            }
        }
        .onAppear {
            widget.connect()
        }
        .onDisappear {
            widget.stopEmulate()
        }
        .onChange(of: widget.keyToEmulate) { _ in
            feedback(style: .soft)
        }
    }
}
