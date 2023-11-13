import Core
import SwiftUI
import ActivityKit

struct DeviceUpdateView: View {
    @EnvironmentObject var update: UpdateModel
    @EnvironmentObject var device: Device
    @Environment(\.dismiss) var dismiss
    @Environment(\.scenePhase) var scenePhase

    @State private var state: UpdateModel.State = .update(.progress(.preparing))
    @State private var activity: Any?
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

    @ViewBuilder
    var flipperImage: some View {
        switch state {
        case .error(let error):
            switch error {
            case .noInternet, .noDevice, .cantConnect:
                FlipperDeadImage()
            case .noCard:
                FlipperFlashingIssueImage()
            }
        default:
            FlipperUpdatingImage()
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
            flipperImage
                .flipperColor(device.flipper?.color)
                .padding(.leading, 22)
                .padding(.trailing, 32)
                .padding(.top, 19)

            switch state {
            case .error(.cantConnect):
                NoInternetView { start() }
                    .padding(.top, 38)
            case .error(.noDevice):
                NoDeviceView()
                    .padding(.top, 38)
            case .error(.noCard):
                StorageErrorView()
                    .padding(.top, 24)
            case .update(.progress(let state)):
                UpdateProgressView(
                    state: state,
                    version: version,
                    changelog: changelog
                )
                .padding(.top, 14)
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
                title: Text("Stop Update?"),
                message: Text(
                    "Flipper will still have the previous firmware version"
                ),
                primaryButton: .default(.init("Continue")),
                secondaryButton: .default(.init("Stop")) {
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
            startActivity()
            start()
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            stopActivity()
        }
        .onChange(of: update.state) { newState in
            updateActivity(newState)
        }
        .onChange(of: scenePhase) { newValue in
            UIApplication.shared.isIdleTimerDisabled = newValue == .active
        }
    }

    func start() {
        update.install(firmware)
    }

    func startActivity() {
        if #available(iOS 16.2, *), !ProcessInfo.processInfo.isiOSAppOnMac {
            let attributes = UpdateActivityAttibutes(version: firmware.version)
            activity = try? Activity<UpdateActivityAttibutes>.request(
                attributes: attributes,
                content: .init(state: .progress(.preparing), staleDate: nil))
        }
    }

    func stopActivity() {
        if #available(iOS 16.2, *), !ProcessInfo.processInfo.isiOSAppOnMac {
            var activity: Activity<UpdateActivityAttibutes>? {
                self.activity as? Activity<UpdateActivityAttibutes>
            }
            Task {
                let deadline = Date.now.addingTimeInterval(7)
                await activity?.end(.none, dismissalPolicy: .after(deadline))
            }
        }
    }

    func updateActivity(_ state: UpdateModel.State) {
        if #available(iOS 16.2, *), !ProcessInfo.processInfo.isiOSAppOnMac {
            var activity: Activity<UpdateActivityAttibutes>? {
                self.activity as? Activity<UpdateActivityAttibutes>
            }
            Task {
                switch state {

                case .update(.progress(let progress)):
                    await activity?.update(.init(
                        state: .progress(progress),
                        staleDate: .now.addingTimeInterval(6)))

                case .update(.result(let result)):
                    await activity?.update(.init(
                        state: .result(result),
                        staleDate: nil))
                    stopActivity()

                case .error:
                    await activity?.update(.init(
                        state: .result(.canceled),
                        staleDate: nil))
                    stopActivity()

                default:
                    break
                }
            }
        }
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
