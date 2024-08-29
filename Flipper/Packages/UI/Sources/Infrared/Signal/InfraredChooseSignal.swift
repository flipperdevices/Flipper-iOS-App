import Core

import SwiftUI

extension InfraredView {
    struct InfraredChooseSignal: View {
        @EnvironmentObject private var emulate: Emulate
        @EnvironmentObject private var device: Device
        @EnvironmentObject private var infraredModel: InfraredModel

        @Environment(\.dismiss) private var dismiss
        @Environment(\.path) private var path

        @State private var signal: InfraredSignal?
        @State private var showConfirmDialog: Bool = false

        @State private var successSignals: [Int] = []
        @State private var failedSignals: [Int] = []
        @State private var isSingleSignal: Bool = false

        @State private var isEmulating = false
        @State private var isFlipperBusyAlertPresented: Bool = false
        @State private var showRemoteControl = false

        @State private var viewState: ViewState = .loadSignal

        enum ViewState {
            case loadSignal
            case flipperNotConnected
            case display(InfraredSignal, InfraredLayoutState)
            case error(InfraredModel.Error.Network)
        }

        let brand: InfraredBrand

        var body: some View {
            VStack(spacing: 0) {
                switch viewState {
                case .loadSignal:
                    VStack(alignment: .center, spacing: 14) {
                        Text("Checking Configurations")
                            .font(.system(size: 16, weight: .bold))
                            .padding(.top, 18)

                        Spacer()

                        InfraredButtonTypeView(data: .unknown)
                            .frame(width: 60, height: 60)
                            .environment(\.layoutState, .syncing)

                        AnimatedPlaceholder()
                            .frame(width: 200, height: 20)

                        AnimatedPlaceholder()
                            .frame(width: 150, height: 20)

                        Spacer()
                    }
                case .error(let error):
                    InfraredNetworkError(error: error, action: retry)
                case .flipperNotConnected:
                    InfraredFlipperNotConnectedError()
                case .display(let signal, let state):
                    VStack(alignment: .center, spacing: 14) {
                        Text("Checking Configurations")
                            .font(.system(size: 16, weight: .bold))
                            .padding(.top, 18)

                        Spacer()

                        InfraredButtonTypeView(data: signal.button)
                            .frame(width: 60, height: 60)
                            .environment(\.layoutState, state)
                            .environment(\.emulateAction, onStartEmulate)

                        Text(
                            "Point your Flipper Zero at the device\n" +
                            "and tap the button above"
                        )
                        .font(.system(size: 14, weight: .medium))
                        .multilineTextAlignment(.center)

                        Spacer()
                    }
                    .padding(.horizontal, 12)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackground(Color.a1)
            .toolbar {
                LeadingToolbarItems {
                    BackButton {
                        dismiss()
                    }
                }
                PrincipalToolbarItems {
                    Title("Set Up Remote", description: "Step 3 of 3")
                }
            }
            .sheet(
                isPresented: $showConfirmDialog,
                onDismiss: onDismissSheet
            ) {
                if let signal {
                    InfraredChooseSignalSheet(
                        message: signal
                            .message
                            .replacing("%s", with: signal.category),
                        onConfirm: processConfirmSignal
                    )
                    .presentationDragIndicator(.hidden)
                    .presentationDetents([.height(150)])
                    .pickerStyle(.segmented)
                }
            }
            .alert(isPresented: $isFlipperBusyAlertPresented) {
                FlipperIsBusyAlert(
                    isPresented: $isFlipperBusyAlertPresented,
                    goToRemote: { showRemoteControl = true }
                )
            }
            .sheet(isPresented: $showRemoteControl) {
                RemoteControlView()
                    .environmentObject(device)
            }
            .task {
                if device.status != .connected {
                    viewState = .flipperNotConnected
                    return
                }
                // Disable loop when we found signal and go layout
                if isSingleSignal {
                    dismiss()
                    return
                }
                await loadSignal()
            }
            .onChange(of: device.status) { status in
                if status != .connected {
                    showConfirmDialog = false
                    viewState = .flipperNotConnected
                } else {
                    retry()
                }
            }
            .onChange(of: emulate.state) { state in
                guard let signal else { return }

                if state == .closed {
                    viewState = .display(signal, .default)
                    showConfirmDialog = true
                }
                if state == .locked {
                    viewState = .display(signal, .default)
                    isFlipperBusyAlertPresented = true
                }
                if state == .staring || state == .started || state == .closed {
                    feedback(style: .soft)
                }
            }
        }

        private func loadSignal() async {
            do {
                viewState = .loadSignal
                let selection = try await infraredModel
                    .loadSignal(
                        brand: brand,
                        successSignals: successSignals,
                        failedSignals: failedSignals
                    )

                switch selection {
                case .signal(let signal):
                    self.signal = signal
                    try await infraredModel.sendTempContent(signal.content)

                    viewState = .display(signal, .default)
                case .file(let file):
                    if successSignals.isEmpty && failedSignals.isEmpty {
                        isSingleSignal = true
                    }

                    successSignals = []
                    failedSignals = []
                    path.append(Destination.layout(file))
                }
            } catch let error as InfraredModel.Error.Network {
                viewState = .error(error)
            } catch {}
        }

        private func onStartEmulate(_ keyID: InfraredKeyID) {
            guard let signal = signal else { return }
            viewState = .display(signal, .emulating)
            emulate.startEmulate(.tempIfr, config: .byIndex(0))
        }

        private func processConfirmSignal(isSuccess: Bool) {
            guard let signal = signal else { return }
            showConfirmDialog = false

            if isSuccess {
                successSignals.append(signal.id)
            } else {
                failedSignals.append(signal.id)
            }

            Task { await loadSignal() }
        }

        private func onDismissSheet() {
            guard let signal = signal else { return }
            viewState = .display(signal, .default)
        }

        private func retry() {
            Task { await loadSignal() }
        }
    }
}
