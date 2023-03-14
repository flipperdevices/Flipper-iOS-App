import Core
import Peripheral

import SwiftUI

struct RemoteControlView: View {
    @EnvironmentObject var device: Device
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dismiss) private var dismiss

    var uiImage: UIImage {
        .init(
            pixels: device.frame.pixels.map { $0 ? .black : .orange },
            width: 128,
            height: 64
        ) ?? .init()
    }

    var screenshotImage: UIImage {
        uiImage.resized(to: .init(
            width: 512,
            height: 256))
    }

    var screenshotName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.string(from: .now)
        formatter.dateFormat = "HH.mm.ss"
        let time = formatter.string(from: .now)
        return "Screenshot \(date) at \(time)"
    }

    var body: some View {
        VStack {
            HStack {
                VStack(spacing: 8) {
                    Button {
                        screenshot()
                    } label: {
                        Image("RemoteScreenshot")
                    }
                    Text("Screenshot")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.a1)
                }
                Spacer()
                VStack(spacing: 8) {
                    Button {
                        device.isLocked ? unlock() : lock()
                    } label: {
                        Image(device.isLocked ? "RemoteUnlock" : "RemoteLock")
                    }

                    ZStack {
                        Text("Lock Flipper")
                            .opacity(device.isLocked ? 0 : 1)

                        Text("Unlock Flipper")
                            .opacity(device.isLocked ? 1 : 0)
                    }
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
                DeviceScreen(uiImage)
                    .padding(.horizontal, 24)

                Image("RemoteFlipperLogo")
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, 96)
            }

            Spacer(minLength: 14)

            DeviceControls { button in
                pressButton(button)
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
            device.updateLockStatus()
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

    func screenshot() {
        guard
            let data = screenshotImage.pngData(),
            let url = try? FileManager.default.createTempFile(
                name: "\(screenshotName).png",
                data: data
            )
        else {
            return
        }
        UI.share(url) {
            try? FileManager.default.removeItem(at: url)
        }
    }

    @State var isBusy = false

    private func syncTask(_ task: @escaping () async throws -> Void) {
        guard !isBusy else { return }
        isBusy = true
        Task {
            try await task()
            isBusy = false
        }
    }

    func pressButton(_ button: InputKey) {
        syncTask {
            feedback(style: .light)
            try await device.pressButton(button)
        }
    }

    func lock() {
        syncTask {
            try await device.lock()
            device.updateLockStatus()
        }
    }

    func unlock() {
        syncTask {
            try await device.unlock()
            device.updateLockStatus()
        }
    }
}

private extension UIImage {
    func scaled(by scale: Double) -> UIImage {
        resized(to: .init(
            width: size.width * scale,
            height: size.height * scale))
    }

    func resized(
        to size: CGSize,
        interpolationQuality: CGInterpolationQuality = .none,
        isOpaque: Bool = true
    ) -> UIImage {
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: size, format: format).image {
            $0.cgContext.interpolationQuality = interpolationQuality
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
