import Core
import SwiftUI

struct RemoteControlView: View {
    @EnvironmentObject var device: Device
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            HStack {
                VStack(spacing: 8) {
                    Image("RemoteScreenshot")
                    Text("Screenshot")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.a1)
                }
                Spacer()
                VStack(spacing: 8) {
                    Image("RemoteUnlock")
                    Text("Lock Flipper")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.a1)
                }
            }
            .padding(.top, 14)
            .padding(.horizontal, 36)

            Spacer(minLength: 0)
            Spacer(minLength: 0)
            Spacer(minLength: 14)

            VStack(spacing: 14){
                DeviceScreen(pixels: device.frame.pixels)
                    .padding(.horizontal, 24)

                Image("RemoteFlipperLogo")
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, 96)
            }

            Spacer(minLength: 14)

            DeviceControls { button in
                feedback(style: .light)
                device.pressButton(button)
            }
            .padding(.bottom, 14)
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
            device.startScreenStreaming()
        }
        .onDisappear {
            device.stopScreenStreaming()
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active: device.startScreenStreaming()
            case .inactive: device.stopScreenStreaming()
            case .background: break
            @unknown default: break
            }
        }
    }
}
