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

    var normalizedImage: UIImage {
        switch device.frame.orientation {
        case .horizontalFlipped: return uiImage.withOrientation(.down)
        default: return uiImage
        }
    }

    var screenshotImage: UIImage {
        normalizedImage.resized(to: .init(
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

    //--------------------------------------------------------------------------
    @State var controlsQueue: [(UUID, InputKey)] = []
    @State var controlsStream: AsyncStream<InputKey>?
    @State var controlsStreamContinuation: AsyncStream<InputKey>.Continuation?
    //--------------------------------------------------------------------------

    var body: some View {
        VStack {
            HStack {
                ScreenshotButton {
                    screenshot()
                }
                Spacer()
                LockButton(isLocked: device.isLocked) {
                    device.isLocked ? unlock() : lock()
                }
            }
            .padding(.top, 14)
            .padding(.horizontal, 36)

            Spacer(minLength: 0)
            Spacer(minLength: 0)
            Spacer(minLength: 14)

            VStack(spacing: 14) {
                VStack(spacing: 0) {
                    ControlsQueue($controlsQueue)
                    DeviceScreen(normalizedImage)
                }
                .padding(.horizontal, 24)

                Image("RemoteFlipperLogo")
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, 96)
            }

            Spacer(minLength: 14)

            DeviceControls { button in
                buttonTapped(button)
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
        .task {
            await runLoop()
        }
    }

    func runLoop() async {
        let controlsStream = AsyncStream<InputKey> { continuation in
            controlsStreamContinuation = continuation
        }
        self.controlsStream = controlsStream
        for await next in controlsStream {
            await pressButton(next)
            withAnimation {
                controlsQueue = .init(controlsQueue.dropFirst())
            }
        }
    }

    func buttonTapped(_ button: InputKey) {
        controlsQueue.append((.init(), button))
        controlsStreamContinuation?.yield(button)
    }

    func pressButton(_ button: InputKey) async {
        feedback(style: .light)
        try? await device.pressButton(button)
        feedback(style: .light)
    }

    func lock() {
        // FIXME: add .lock button
        guard controlsQueue.isEmpty else { return }
        Task {
            try await device.lock()
            device.updateLockStatus()
        }
    }

    func unlock() {
        // FIXME: add .unlock button
        guard controlsQueue.isEmpty else { return }
        Task {
            try await device.unlock()
            device.updateLockStatus()
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

    func withOrientation(_ orientation: Orientation) -> UIImage {
        guard let cgImage = self.cgImage else {
            return .init()
        }
        return .init(cgImage: cgImage, scale: 1.0, orientation: orientation)
    }
}
