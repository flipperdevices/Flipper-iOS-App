import Core
import SwiftUI

struct RemoteControlView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var flipperService: FlipperService
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            Spacer()

            DeviceScreen(pixels: flipperService.frame.pixels)
                .padding(2)
                .border(Color(red: 1, green: 0.51, blue: 0), width: 2)

            Spacer()

            DeviceControls { button in
                feedback(style: .light)
                flipperService.pressButton(button)
            }
            .padding(.bottom, 50)
        }
        .frame(maxWidth: .infinity)
        .background(Color.background)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LeadingToolbarItems {
                BackButton {
                    dismiss()
                }
                Title("Remote Control")
            }
        }
        .onAppear {
            flipperService.startScreenStreaming()
            recordRemoteControl()
        }
        .onDisappear {
            flipperService.stopScreenStreaming()
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active: flipperService.startScreenStreaming()
            case .inactive: flipperService.stopScreenStreaming()
            case .background: break
            @unknown default: break
            }
        }
    }

    // MARK: Analytics

    func recordRemoteControl() {
        appState.analytics.appOpen(target: .remoteControl)
    }
}
