import Core
import Peripheral
import SwiftUI

struct DeviceUpdateView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var updateService: UpdateService

    @AppStorage(.isProvisioningDisabled) var isProvisioningDisabled = false
    @State var showCancelUpdate = false

    @Binding var isPresented: Bool
    let channel: Update.Channel
    let firmware: Update.Manifest.Version?
    let onSuccess: @MainActor () -> Void
    let onFailure: @MainActor (Update.State.Error) -> Void

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
        case .error(.outdatedApp): return "Unable to Update"
        case .error(.noDevice): return "Update Failed"
        default: return "Updating your Flipper"
        }
    }

    var image: String {
        switch appState.update.state {
        case .error(.noCard):
            return "FlipperNoCard"
        case .error(.noInternet), .error(.noDevice), .error(.outdatedApp):
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
        guard let firmware = firmware else { return "" }
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
        guard let firmware = firmware else { return "" }
        return firmware.changelog
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
            case .error(.failedDownloading): NoInternetView { update() }
            case .error(.noInternet): NoInternetView { update() }
            case .error(.noDevice): NoDeviceView()
            case .error(.failedUploading): StorageErrorView()
            case .error(.storageError): StorageErrorView()
            case .error(.outdatedApp): OutdatedAppView()
            case .update(let state):
                UpdateProgressView(
                    state: state,
                    changelog: changelog,
                    availableFirmware: availableFirmware,
                    availableFirmwareColor: availableFirmwareColor)
            default:
                // TODO: should we handle other cases?
                Text(String(describing: appState.update.state))
            }

            Spacer()
            Button {
                isUpdating
                    ? confirmCancel()
                    : close()
            } label: {
                Text(isUpdating ? "Cancel" : "Close")
                    .font(.system(size: 16, weight: .medium))
            }
            .padding(.bottom, 8)
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
            update()
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
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
    }

    func update() {
        updateService.update(
            firmware: firmware,
            isProvisioningDisabled: isProvisioningDisabled,
            onSuccess: {
                onSuccess()
                close()
            },
            onFailure: { error in
                onFailure(error)
            })
    }

    func confirmCancel() {
        showCancelUpdate = true
    }

    func cancel() {
        Task {
            updateService.cancel()
            appState.disconnect()
            onFailure(.canceled)
            close()
            try await Task.sleep(milliseconds: 100)
            appState.connect()
        }
    }

    func close() {
        isPresented = false
    }
}
