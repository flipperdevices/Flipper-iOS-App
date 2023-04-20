import Core
import Peripheral

import SwiftUI

struct RemoteControlView: View {
    @EnvironmentObject var device: Device
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dismiss) private var dismiss

    var uiImage: UIImage? {
        guard let frame = device.frame else { return nil }
        return .init(
            pixels: frame.pixels.map { $0 ? .black : .orange },
            width: 128,
            height: 64
        )
    }

    var normalizedImage: UIImage? {
        guard let frame = device.frame, let image = uiImage else {
            return nil
        }
        switch frame.orientation {
        case .horizontalFlipped: return image.withOrientation(.down)
        default: return image
        }
    }

    var screenshotImage: UIImage? {
        normalizedImage?.resized(to: .init(
            width: 512,
            height: 256))
    }

    var screenshotName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.string(from: Date())
        formatter.dateFormat = "HH.mm.ss"
        let time = formatter.string(from: Date())
        return "Screenshot \(date) at \(time)"
    }

    //--------------------------------------------------------------------------
    @State var controlsQueue: [(UUID, InputKey)] = []
    @State var controlsStream: AsyncStream<InputKey>?
    @State var controlsStreamContinuation: AsyncStream<InputKey>.Continuation?
    //--------------------------------------------------------------------------

    @Namespace var namespace

    @State private var isHorizontal = false
    @State private var showOutdatedAlert = false

    @State private var deviceSize: CGSize = .zero
    @State private var screenRect: CGRect = .zero

    var displayOffset: Double { 0.6 }
    var buttonSide: Double { 90 }
    var buttonPadding: Double { 12 }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                GeometryReader { proxy in
                    var width: Double {
                        isHorizontal
                            ? proxy.size.width
                            : min(proxy.size.width, proxy.size.height)
                    }

                    var rotation: Angle {
                        .degrees(isHorizontal ? 0 : 90)
                    }

                    var offset: Double {
                        max(0, proxy.size.height - deviceSize.height) * 0.8
                    }

                    var screenOffset: Double { screenRect.origin.y }
                    var screenWidth: Double { screenRect.width }

                    var screenshotOffsetX: Double {
                        isHorizontal
                            ? buttonPadding
                            : screenRect.width - buttonSide - buttonPadding
                    }

                    var screenshotOffsetY: Double {
                        isHorizontal
                            ? 0
                            : screenOffset - screenRect.width / 2
                    }

                    var lockOffsetX: Double {
                        screenRect.width - buttonSide - buttonPadding
                    }

                    var lockOffsetY: Double {
                        isHorizontal
                            ? 0
                            : screenOffset + screenRect.width / 2 - buttonSide
                    }

                    ScreenshotButton {
                        screenshot()
                    }
                    .frame(width: buttonSide, height: buttonSide)
                    .offset(x: screenshotOffsetX)
                    .offset(y: screenshotOffsetY)

                    LockButton(isLocked: false) {
                        showOutdatedAlert = true
                    }
                    .opacity(0.5)
                    .frame(width: buttonSide, height: buttonSide)
                    .offset(x: lockOffsetX)
                    .offset(y: lockOffsetY)

                    VStack(spacing: 8) {
                        ControlsQueue($controlsQueue)
                            .padding(.horizontal, 4)
                            .opacity(isHorizontal ? 1 : 0)

                        DeviceScreen {
                            if device.status == .disconnected {
                                Image("RemoteNotConnected")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } else if let uiImage = uiImage {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .interpolation(.none)
                                    .aspectRatio(contentMode: .fit)
                            } else {
                                AnimatedPlaceholder()
                            }
                        }
                        .rotationEffect(rotation, anchor: .bottomTrailing)
                        .frame(width: width)
                        .offset(x: isHorizontal ? 0 : -width)
                        .captureFrame(in: $screenRect, space: .named("rcp"))

                        FlipperLogo()
                            .frame(width: width * 0.55)
                            .opacity(isHorizontal ? 1 : 0)
                    }
                    .captureSize(in: $deviceSize)
                    .offset(y: offset)
                }
            }
            .padding(.top, 14)
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .coordinateSpace(name: "rcp")

            DeviceControls { button in
                buttonTapped(button)
            }
            .padding(.bottom, 14)
        }
        .onChange(of: device.frame) { frame in
            withAnimation {
                isHorizontal = frame?.orientation.isHorizontal ?? true
            }
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
        .customAlert(isPresented: $showOutdatedAlert) {
            OutdatedVersionAlert(isPresented: $showOutdatedAlert)
        }
        .task {
            isHorizontal = device.frame?.orientation.isHorizontal ?? true
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
            let data = screenshotImage?.pngData(),
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

private struct SizeKey: PreferenceKey {
    static let defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

private extension View {
    func captureSize(in binding: Binding<CGSize>) -> some View {
        overlay(GeometryReader { proxy in
            Color.clear.preference(key: SizeKey.self, value: proxy.size)
        })
        .onPreferenceChange(SizeKey.self) { binding.wrappedValue = $0 }
    }
}

private struct RectKey: PreferenceKey {
    static let defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

private extension View {
    func captureFrame(
        in binding: Binding<CGRect>,
        space: CoordinateSpace
    ) -> some View {
        overlay(GeometryReader { proxy in
            Color.clear.preference(
                key: RectKey.self,
                value: proxy.frame(in: space))
        })
        .onPreferenceChange(RectKey.self) { binding.wrappedValue = $0 }
    }
}
