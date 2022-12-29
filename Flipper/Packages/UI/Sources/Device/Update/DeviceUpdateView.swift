import Core
import SwiftUI

struct DeviceUpdateView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var updateService: UpdateService
    @EnvironmentObject var flipperService: FlipperService
    @Environment(\.dismiss) var dismiss

    @State var showCancelUpdate = false

    let intent: Update.Intent

    var channel: Update.Channel {
        intent.to.channel
    }
    var firmware: Update.Manifest.Version {
        intent.to.firmware
    }

    var isUpdating: Bool {
        switch appState.update.state {
        case .update(.downloading), .update(.preparing), .update(.uploading):
            return true
        default:
            return false
        }
    }

    var title: String {
        switch appState.update.state {
        case .error(.noInternet), .error(.noCard): return "Update Not Started"
        case .error(.storageError): return "Unable to Update"
        case .error(.noDevice): return "Update Failed"
        default: return "Updating your Flipper"
        }
    }

    var image: String {
        switch appState.update.state {
        case .error(.noCard):
            return "FlipperNoCard"
        case .error(.noInternet), .error(.noDevice), .error(.cantConnect):
            switch appState.flipper?.color {
            case .black: return "FlipperDeadBlack"
            default: return "FlipperDeadWhite"
            }
        case .error(.storageError):
            switch appState.flipper?.color {
            case .black: return "FlipperFlashIssueBlack"
            default: return "FlipperFlashIssueWhite"
            }
        default:
            switch appState.flipper?.color {
            case .black: return "FlipperUpdatingBlack"
            default: return "FlipperUpdatingWhite"
            }
        }
    }

    var availableFirmware: String {
        switch channel {
        case .development: return "Dev \(firmware.version)"
        case .candidate: return "RC \(firmware.version.dropLast(3))"
        case .release: return "Release \(firmware.version)"
        case .custom(let url): return "Custom \(url.lastPathComponent)"
        }
    }

    var availableFirmwareColor: Color {
        switch channel {
        case .development: return .development
        case .candidate: return .candidate
        case .release: return .release
        case .custom: return .custom
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

            switch appState.update.state {
            case .error(.cantConnect): NoInternetView { start() }
            case .error(.failedDownloading): NoInternetView { start() }
            case .error(.noInternet): NoInternetView { start() }
            case .error(.noDevice): NoDeviceView()
            case .error(.noCard): StorageErrorView()
            case .error(.failedPreparing): StorageErrorView()
            case .error(.failedUploading): StorageErrorView()
            case .error(.storageError): StorageErrorView()
            case .error(.outdatedApp): OutdatedAppView()
            case .error(.canceled): CanceledView()
            case .update(let state):
                UpdateProgressView(
                    state: state,
                    changelog: changelog,
                    availableFirmware: availableFirmware,
                    availableFirmwareColor: availableFirmwareColor)
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
        .onChange(of: appState.update.state) { state in
            if state == .update(.started) {
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
        updateService.start(intent)
    }

    func confirmCancel() {
        showCancelUpdate = true
    }

    func cancel() {
        updateService.cancel()
        dismiss()
    }
}
