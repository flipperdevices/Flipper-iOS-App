import Core
import SwiftUI

struct DeviceUpdateView: View {
    @EnvironmentObject var update: UpdateModel
    @EnvironmentObject var device: Device
    @Environment(\.dismiss) var dismiss

    @State private var state: UpdateModel.State = .update(.progress(.preparing))
    @State private var showCancelUpdate = false

    let firmware: Update.Firmware

    var version: Update.Version {
        firmware.version
    }

    var isUpdating: Bool {
        switch state {
        case .update: return true
        default: return false
        }
    }

    var title: String {
        switch state {
        case .error(.noInternet): return "Update Not Started"
        case .error(.noCard): return "Unable to Update"
        case .error(.noDevice): return "Update Failed"
        default: return "Updating your Flipper"
        }
    }

    var image: String {
        switch state {
        case .error(let error):
            switch error {
            case .noInternet, .noDevice, .cantConnect:
                switch device.flipper?.color {
                case .black: return "FlipperDeadBlack"
                default: return "FlipperDeadWhite"
                }
            case .noCard:
                switch device.flipper?.color {
                case .black: return "FlipperFlashIssueBlack"
                default: return "FlipperFlashIssueWhite"
                }
            }
        default:
            switch device.flipper?.color {
            case .black: return "FlipperUpdatingBlack"
            default: return "FlipperUpdatingWhite"
            }
        }
    }

    var changelog: String {
        firmware.changelog
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

            switch state {
            case .error(.cantConnect): NoInternetView { start() }
            case .error(.noDevice): NoDeviceView()
            case .error(.noCard): StorageErrorView()
            case .update(.progress(let state)):
                UpdateProgressView(
                    state: state,
                    version: version,
                    changelog: changelog)
            default:
                EmptyView()
            }

            Spacer()
            Button {
                isUpdating
                    ? confirmCancel()
                    : dismiss()
            } label: {
                Text(isUpdating ? "Cancel" : "Close")
                    .font(.system(size: 16, weight: .medium))
            }
            .padding(.bottom, 8)
        }
        .alert(isPresented: $showCancelUpdate) {
            Alert(
                title: Text("Abort Update?"),
                message: Text(
                    "Updating will be interrupted. " +
                    "Flipper will still have the previous firmware version."),
                primaryButton: .default(.init("Continue")),
                secondaryButton: .default(.init("Abort")) {
                    cancel()
                })
        }
        .onChange(of: update.state) { newState in
            switch newState {
            case .update(.progress), .error:
                state = newState
            case .update(.result):
                dismiss()
            default:
                break
            }
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
            start()
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }

    func start() {
        state = .initial
        update.install(firmware)
    }

    func confirmCancel() {
        showCancelUpdate = true
    }

    func cancel() {
        update.cancel()
        dismiss()
    }
}

private extension UpdateModel.State {
    static let initial: Self = .update(.progress(.preparing))
}
