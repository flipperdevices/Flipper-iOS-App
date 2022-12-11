import Core
import Inject

import Logging
import SwiftUI

public struct WidgetView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var flipperService: FlipperService
    @EnvironmentObject var widgetService: WidgetService

    var widget: WidgetModel {
        appState.widget
    }

    public var isError: Bool {
        widget.isError
    }

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            Divider()
                .foregroundColor(.black4)

            switch widget.state {
            case .idle, .emulating:
                WidgetKeysView(
                    keys: widget.keys,
                    keyToEmulate: widget.keyToEmulate,
                    isExpanded: widgetService.isExpanded,
                    onSendPressed: { widgetService.onSendPressed(for: $0) },
                    onSendReleased: { widgetService.onSendReleased(for: $0) },
                    onEmulateTapped: { widgetService.onEmulateTapped(for: $0) }
                )
            case .loading:
                Text("Loading")
            case .error(let error):
                ErrorView(error: error) {
                    print("on back")
                }
            }
        }
        .onAppear {
            flipperService.connect()
        }
        .onDisappear {
            widgetService.stopEmulate()
            flipperService.disconnect()
        }
        .edgesIgnoringSafeArea(.all)
        .onChange(of: appState.emulate.state) { state in
            if
                state == .staring ||
                state == .started ||
                state == .closed
            {
                feedback(style: .soft)
            }
        }
    }
}
