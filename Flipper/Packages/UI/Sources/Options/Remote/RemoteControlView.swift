import Core
import SwiftUI
import Peripheral

struct RemoteControlView: View {
    @StateObject var viewModel: RemoteControlViewModel
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dismiss) private var dismiss

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
                    dismiss()
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

    var scaledWidth: Double { Double(.screenWidth * .scale) }
    var scaledHeight: Double { Double(.screenHeight * .scale) }

    var colorPixels: [PixelColor] {
        self.pixels.map { $0 ? .black : .orange }
    }

    var uiImage: UIImage {
        UIImage(pixels: colorPixels, width: .screenWidth, height: .screenHeight)
            ?? .init()
    }

    var body: some View {
        Image(uiImage: uiImage)
            .resizable()
            .interpolation(.none)
            .frame(width: scaledWidth, height: scaledHeight)
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
