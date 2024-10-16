import Core

import SwiftUI

extension InfraredView {
    struct InfraredChooseSignal: View {
        @EnvironmentObject private var emulate: Emulate
        @EnvironmentObject private var device: Device
        @EnvironmentObject private var infraredModel: InfraredModel

        @Environment(\.dismiss) private var dismiss
        @Environment(\.path) private var path

        @State private var currentSignal: InfraredSignal?

        @State private var showConfirmDialog: Bool = false
        @State private var isFinalSignal: Bool = false

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
        let signals: InfraredSignals

        init(
            brand: InfraredBrand,
            signals: InfraredSignals
        ) {
            self.brand = brand
            self.signals = signals
        }

        var body: some View {
            VStack(spacing: 0) {
                switch viewState {
                case .loadSignal:
                    InfraredChooseSignalView(
                        button: .unknown,
                        state: .syncing,
                        onStartEmulate: { _ in },
                        onSkip: {}
                    )
                case .error(let error):
                    InfraredNetworkError(error: error, action: retry)
                case .flipperNotConnected:
                    InfraredFlipperNotConnectedError()
                case .display(let signal, let state):
                    InfraredChooseSignalView(
                        button: signal.button,
                        state: state,
                        onStartEmulate: onStartEmulate,
                        onSkip: { processConfirmSignal(type: .skipped) }
                    )
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
                if let signal = currentSignal {
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

                // Disable loop when we found file
                if isFinalSignal {
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
                guard let signal = currentSignal else { return }

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
                        successSignals: signals.successSignals,
                        failedSignals: signals.failedSignals,
                        skippedSignals: signals.skippedSignals
                    )

                switch selection {
                case .signal(let signal):
                    self.currentSignal = signal
                    try await infraredModel.sendTempContent(signal.content)

                    viewState = .display(signal, .default)
                case .file(let file):
                    isFinalSignal = true
                    path.append(Destination.layout(file))
                }
            } catch let error as InfraredModel.Error.Network {
                viewState = .error(error)
            } catch {}
        }

        private func onStartEmulate(_ keyID: InfraredKeyID) {
            guard let signal = currentSignal else { return }
            viewState = .display(signal, .emulating)
            emulate.startEmulate(.tempIfr, config: .byIndex(0))
        }

        private func processConfirmSignal(type: InfraredChooseSignalType) {
            guard let signal = currentSignal else { return }
            showConfirmDialog = false

            var newSignals = signals
            newSignals[signal] = type
            path.append(Destination.chooseSignal(brand, newSignals))
        }

        private func onDismissSheet() {
            guard let signal = currentSignal else { return }
            viewState = .display(signal, .default)
        }

        private func retry() {
            Task { await loadSignal() }
        }
    }
}

private extension Dictionary
    where Key == InfraredSignal, Value == InfraredChooseSignalType {

    private func signals(for type: InfraredChooseSignalType) -> [Int] {
        self.filter { _, value in value == type }.map(\.key.id)
    }

    var successSignals: [Int] {
        self.signals(for: .success)
    }

    var failedSignals: [Int] {
        self.signals(for: .failed)
    }

    var skippedSignals: [Int] {
        self.signals(for: .skipped)
    }
}
