import SwiftUI

struct DeviceUpdateView: View {
    @StateObject var viewModel: DeviceUpdateViewModel

    var description: String {
        switch viewModel.state {
        case .downloadingFirmware:
            return "Downloading from update server..."
        case .prepearingForUpdate:
            return "Preparing for update..."
        case .uploadingFirmware:
            return "Uploading firmware to Flipper..."
        case .canceling:
            return "Canceling..."
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("Updating your Flipper")
                .font(.system(size: 18, weight: .bold))
                .padding(.top, 48)
            Image("FlipperWhite")
                .resizable()
                .padding(.horizontal, 14)
                .scaledToFit()
                .padding(.top, 22)
            Text(viewModel.availableFirmware)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(viewModel.availableFirmwareColor)
                .padding(.top, 64)
            UpdateProgress(viewModel: viewModel)
                .padding(.top, 12)
                .padding(.horizontal, 24)
            Text(description)
                .font(.system(size: 14, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.black30)
                .padding(.top, 8)
            Spacer()
            Button {
                viewModel.cancel()
            } label: {
                Text("Cancel")
                    .font(.system(size: 16, weight: .medium))
            }
            .padding(.bottom, 8)
        }
        .onAppear {
            viewModel.update()
        }
    }
}

struct UpdateProgress: View {
    @StateObject var viewModel: DeviceUpdateViewModel

    var image: String {
        switch viewModel.state {
        case .downloadingFirmware: return "DownloadingUpdate"
        default: return "UploadingUpdate"
        }
    }

    var color: Color {
        switch viewModel.state {
        case .downloadingFirmware: return .sGreenUpdate
        case .prepearingForUpdate, .uploadingFirmware, .canceling: return .a2
        }
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 9)
                .stroke(color, lineWidth: 3)

            GeometryReader { reader in
                color.frame(width: reader.size.width / 100 * Double(viewModel.progress))
            }

            HStack {
                Image(image)
                    .padding([.leading, .top, .bottom], 9)

                Spacer()

                if viewModel.state == .prepearingForUpdate {
                    Text("...")
                        .foregroundColor(.white)
                        .font(.custom("HelvetiPixel", fixedSize: 40))
                } else {
                    Text("\(viewModel.progress)%")
                        .foregroundColor(.white)
                        .font(.custom("HelvetiPixel", fixedSize: 40))
                }

                Spacer()

                Image(image)
                    .padding([.leading, .top, .bottom], 9)
                    .opacity(0)
            }
        }
        .frame(height: 46)
        .background(color.opacity(0.54))
        .cornerRadius(9)
    }
}
