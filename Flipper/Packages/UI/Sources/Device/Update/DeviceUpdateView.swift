import SwiftUI

struct DeviceUpdateView: View {
    @StateObject var viewModel: DeviceUpdateViewModel

    var title: String {
        switch viewModel.state {
        case .noInternet, .noCard: return "Update Not Started"
        case .noDevice: return "Update Failed"
        default: return "Updating your Flipper"
        }
    }

    var image: String {
        switch viewModel.state {
        case .noInternet, .noDevice: return "FlipperDead"
        case .noCard: return "FlipperNoCard"
        default: return "FlipperUpdating"
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .padding(.top, 48)
            Image(image)
                .resizable()
                .padding(.horizontal, 14)
                .scaledToFit()
                .padding(.top, 22)

            switch viewModel.state {
            case .noInternet: NoInternetView(viewModel: viewModel)
            case .noDevice: NoDeviceView(viewModel: viewModel)
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
