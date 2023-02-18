import Core
import Logging

import SwiftUI
import NotificationCenter

public struct WidgetView: View {
    @StateObject var widget: WidgetService = .init()

    @StateObject var device: Device = .init(
        pairedDevice: Dependencies.shared.pairedDevice
    )

    @StateObject var emulateService: EmulateService = .init(
        pairedDevice: Dependencies.shared.pairedDevice
    )

    public var isError: Bool {
        widget.isError
    }

    public init() {
    }

    public var body: some View {
        VStack(spacing: 0) {
            Divider()
                .foregroundColor(.black4)

            switch widget.state {
            case .idle, .emulating:
                WidgetKeysView()
                    .environmentObject(widget)
            case .loading:
                Text("Loading")
            case .error(let error):
                ErrorView(error: error) {
                    print("on back")
                }
            }
        }
        .onAppear {
            device.connect()
        }
        .onDisappear {
            widget.stopEmulate()
            device.disconnect()
        }
        .edgesIgnoringSafeArea(.all)
        .onChange(of: emulateService.state) { state in
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
