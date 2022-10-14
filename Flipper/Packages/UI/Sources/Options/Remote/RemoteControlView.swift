import Core
import SwiftUI
import Peripheral

struct RemoteControlView: View {
    @StateObject var viewModel: RemoteControlViewModel
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        VStack {
            Spacer()

            DeviceScreen(pixels: viewModel.frame.pixels)
                .padding(2)
                .border(Color(red: 1, green: 0.51, blue: 0), width: 2)

            Spacer()

            DeviceControls(onButton: viewModel.onButton)
                .padding(.bottom, 50)
        }
        .frame(maxWidth: .infinity)
        .background(Color.background)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LeadingToolbarItems {
                BackButton {
                    presentationMode.wrappedValue.dismiss()
                }
                Title("Remote Control")
            }
        }
        .onAppear {
            viewModel.startStreaming()
        }
        .onDisappear {
            viewModel.stopStreaming()
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active: viewModel.startStreaming()
            case .inactive: viewModel.stopStreaming()
            case .background: break
            @unknown default: break
            }
        }
    }
}

struct DeviceScreen: View {
    var pixels: [Bool]

    var scaledWidth: Int { .screenWidth * .scale }
    var scaledHeight: Int { .screenHeight * .scale }

    let orage = Pixel(a: 255, r: 255, g: 130, b: 0)
    let black = Pixel(a: 255, r: 0, g: 0, b: 0)

    var colorPixels: [Pixel] {
        self.scaledPixels.map { $0 ? black : orage }
    }

    var uiImage: UIImage {
        UIImage(pixels: colorPixels, width: scaledWidth, height: scaledHeight)
            ?? .init()
    }

    var body: some View {
        Image(uiImage: uiImage)
    }

    // sucks but works
    var scaledPixels: [Bool] {
        let newSize = pixels.count * (.scale * .scale)
        var scaled = [Bool](repeating: false, count: newSize)
        for x in 0..<(.screenWidth) {
            for y in 0..<(.screenHeight) {
                let scaledX = x * .scale
                let scaledY = y * .scale
                for newX in scaledX..<(scaledX + .scale) {
                    for newY in scaledY..<(scaledY + .scale) {
                        scaled[newY * scaledWidth + newX] =
                            pixels[y * .screenWidth + x]
                    }
                }
            }
        }
        return scaled
    }
}

struct DeviceControls: View {
    var onButton: @MainActor (InputKey) -> Void

    var width: Double { Double(.controlsWidth * .scale) }
    var height: Double { Double(.controlsHeight * .scale) }

    var body: some View {
        HStack(spacing: 0) {
            VStack {
                Spacer()
                ControlButtonView()
                    .onTapGesture { onButton(.left) }
                Spacer()
            }
            .padding(.leading, 4)
            .frame(width: width / 4)

            VStack {
                ControlButtonView()
                    .onTapGesture { onButton(.up) }
                ControlButtonView()
                    .onTapGesture { onButton(.enter) }
                ControlButtonView()
                    .onTapGesture { onButton(.down) }
            }
            .padding(.bottom, 8)
            .frame(width: width / 4)

            VStack {
                Spacer()
                ControlButtonView()
                    .onTapGesture { onButton(.right) }
                Spacer()
            }
            .padding(.trailing, 4)
            .frame(width: width / 4)

            VStack {
                Circle()
                    .foregroundColor(Color.clear)
                Spacer()
                ControlButtonView()
                    .onTapGesture { onButton(.back) }
            }
            .padding(.top, 24)
            .padding(.trailing, 8)
            .frame(width: width / 4)
        }
        .frame(width: width, height: height)
        .background(
            Image("full")
                .resizable()
                .scaledToFit())
    }
}

struct ControlButtonView: View {
    var body: some View {
        Circle()
            .foregroundColor(Color.white.opacity(0.001))
    }
}

private extension Int {
    static var screenWidth: Int { 128 }
    static var screenHeight: Int { 64 }

    static var controlsWidth: Int { 124 }
    static var controlsHeight: Int { 92 }

    static var scale: Int { 2 }
}
