import SwiftUI

struct DeviceUpdateView: View {
    @StateObject var viewModel: DeviceUpdateViewModel

    var title: String {
        switch viewModel.state {
        case .noInternet, .noCard: return "Update Not Started"
        case .outdatedAppVersion: return "Unable to Update"
        case .noDevice: return "Update Failed"
        default: return "Updating your Flipper"
        }
    }

    var image: String {
        switch viewModel.state {
        case .noCard:
            return "FlipperNoCard"
        case .noInternet, .noDevice, .outdatedAppVersion:
            switch viewModel.deviceColor {
            case .black: return "FlipperDeadBlack"
            default: return "FlipperDeadWhite"
            }
        default:
            switch viewModel.deviceColor {
            case .black: return "FlipperUpdatingBlack"
            default: return "FlipperUpdatingWhite"
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .padding(.top, 12)
            Image(image)
                .resizable()
                .padding(.horizontal, 14)
                .scaledToFit()
                .padding(.top, 22)

            switch viewModel.state {
            case .noInternet: NoInternetView(viewModel: viewModel)
            case .noDevice: NoDeviceView(viewModel: viewModel)
            case .outdatedAppVersion: OutdatedAppView(viewModel: viewModel)
            default: UpdateProgressView(viewModel: viewModel)
            }

            Spacer()
            Button {
                viewModel.confirmCancel()
            } label: {
                Text("Cancel")
                    .font(.system(size: 16, weight: .medium))
            }
            .padding(.bottom, 8)
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
            viewModel.update()
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
        .alert(isPresented: $viewModel.showCancelUpdate) {
            Alert(
                title: Text("Abort Update?"),
                message: Text(
                    "Updating will be interrupted. " +
                    "Flipper will still have the previous firmware version."),
                primaryButton: .default(.init("Continue")),
                secondaryButton: .default(.init("Abort")) {
                    viewModel.cancel()
                })
        }
    }
}
