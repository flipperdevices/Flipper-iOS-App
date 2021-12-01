import Core
import SwiftUI

struct RemoteContolView: View {
    @StateObject var viewModel: RemoteContolViewModel

    var body: some View {
        VStack {
            DeviceScreen(pixels: viewModel.frame.pixels)
                .frame(width: 100, height: 100)

            Spacer()

            DeviceControls(onButton: viewModel.onButton)
                .padding(.bottom, 50)
        }
        .onAppear {
            viewModel.startStreaming()
        }
        .onDisappear {
            viewModel.stopStreaming()
        }
    }
}

struct DeviceScreen: View {
    var pixels: [Bool]

    let scale: Double = 2

    let orage = Pixel(a: 255, r: 190, g: 100, b: 0)
    let black = Pixel(a: 255, r: 0, g: 0, b: 0)

    var colorPixels: [Pixel] {
        self.pixels.map { $0 ? black : orage }
    }

    var uiImage: UIImage {
        UIImage(pixels: colorPixels, width: 128, height: 64) ?? .init()
    }

    var body: some View {
        Image(uiImage: uiImage)
            .resizable()
            .frame(width: 128 * 2, height: 64 * 2)
    }
}

struct DeviceControls: View {
    let scale: Double = 4

    var onButton: (InputKey) -> Void

    var body: some View {
        ZStack {
            Image("full")
                .scaleEffect(scale)

            GeometryReader { proxy in
                HStack(alignment: .bottom, spacing: 0) {
                    VStack {
                        Spacer()
                        ControlButtonView()
                            .onTapGesture { onButton(.left) }
                        Spacer()
                    }
                    .padding(.leading, 4)
                    .frame(width: proxy.size.width / 4)

                    VStack {
                        ControlButtonView()
                            .onTapGesture { onButton(.up) }
                        ControlButtonView()
                            .onTapGesture { onButton(.enter) }
                        ControlButtonView()
                            .onTapGesture { onButton(.down) }
                    }
                    .padding(.bottom, 8)
                    .frame(width: proxy.size.width / 4)

                    VStack {
                        Spacer()
                        ControlButtonView()
                            .onTapGesture { onButton(.right) }
                        Spacer()
                    }
                    .padding(.trailing, 4)
                    .frame(width: proxy.size.width / 4)

                    VStack {
                        Circle()
                            .foregroundColor(Color.clear)
                        Spacer()
                        ControlButtonView()
                            .onTapGesture { onButton(.back) }
                    }
                    .padding(.top, 24)
                    .padding(.trailing, 8)
                    .frame(width: proxy.size.width / 4)
                }
            }
        }
        .frame(width: 62 * scale, height: 45 * scale)
    }
}

struct ControlButtonView: View {
    var body: some View {
        Circle()
            .foregroundColor(Color.white.opacity(0.001))
    }
}
