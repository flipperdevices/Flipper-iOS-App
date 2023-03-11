import Core
import SwiftUI

struct DeviceUpdateView: View {
    @EnvironmentObject var updater: Updater
    @EnvironmentObject var device: Device
    @Environment(\.dismiss) var dismiss

    @State private var showCancelUpdate = false
    @AppStorage(.installingVersion) var installInProgress = ""

    let firmware: Update.Firmware

    var version: Update.Version {
        firmware.version
    }

    var isUpdating: Bool {
        switch updater.state {
        case .busy: return true
        default: return false
        }
    }

    var title: String {
        switch updater.state {
        case .error(.cantDownload): return "Update Not Started"
        case .error(.cantUpload): return "Unable to Update"
        case .error(.cantCommunicate): return "Update Failed"
        default: return "Updating your Flipper"
        }
    }

    var image: String {
        switch updater.state {
        case .error(let error):
            switch error {
            case .cantDownload, .cantCommunicate:
                switch device.flipper?.color {
                case .black: return "FlipperDeadBlack"
                default: return "FlipperDeadWhite"
                }
            case .cantUpload:
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

            switch updater.state {
            case .started, .canceled: EmptyView()
            case .error(.cantDownload): NoInternetView { start() }
            case .error(.cantCommunicate): NoDeviceView()
            case .error(.cantUpload): StorageErrorView()
            case .busy(let state):
                UpdateProgressView(
                    state: state,
                    version: version,
                    changelog: changelog)
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
        .onChange(of: updater.state) { state in
            if state == .started {
                installInProgress = firmware.version.description
            }
            if state == .started || state == .canceled {
                dismiss()
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
        updater.install(firmware)
    }

    func confirmCancel() {
        showCancelUpdate = true
    }

    func cancel() {
        updater.cancel()
        dismiss()
    }
}
