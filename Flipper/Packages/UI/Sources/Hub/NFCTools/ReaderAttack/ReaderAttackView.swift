import Core
import SwiftUI

struct ReaderAttackView: View {
    @StateObject var viewModel: ReaderAttackViewModel
    @StateObject var alertController: AlertController = .init()
    @Environment(\.dismiss) private var dismiss

    var content: some View {
        VStack(spacing: 18) {
            VStack {
                switch viewModel.state {
                case .noLog:
                    ReaderDataNotFound(fliperColor: viewModel.flipperColor)
                case .noDevice:
                    AttackConnectionError(fliperColor: viewModel.flipperColor)
                case .downloadingLog:
                    VStack(spacing: 18) {
                        Text("Calculation Started...")
                            .font(.system(size: 18, weight: .bold))
                        VStack(spacing: 8) {
                            ProgressBarView(
                                image: "ProgressDownload",
                                text: viewModel.progressString,
                                color: .a2,
                                progress: viewModel.progress
                            )
                            .padding(.horizontal, 18)
                            Text("Downloading raw file from Flipper...")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.black40)
                        }
                        Divider()
                    }
                case .calculating:
                    VStack(spacing: 18) {
                        Text("Calculation Started...")
                            .font(.system(size: 18, weight: .bold))
                        VStack(spacing: 8) {
                            ProgressBarView(
                                image: "ProgressKey",
                                text: viewModel.progressString,
                                color: .a1,
                                progress: viewModel.progress
                            )
                            .padding(.horizontal, 18)
                            Text("Calculating...")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.black40)
                        }
                        Divider()
                    }
                case .checkingKeys:
                    VStack(spacing: 18) {
                        Text("Calculation Completed")
                            .font(.system(size: 18, weight: .bold))
                        VStack(spacing: 8) {
                            ProgressBarView(
                                image: "ProgressKey",
                                text: "...",
                                color: .a1,
                                progress: 1
                            )
                            .padding(.horizontal, 18)
                            Text("Checking keys in dictionaries...")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.black40)
                        }
                        Divider()
                    }
                case .uploadingKeys:
                    VStack(spacing: 18) {
                        Text("Calculation Completed")
                            .font(.system(size: 18, weight: .bold))
                        VStack(spacing: 8) {
                            ProgressBarView(
                                image: "ProgressKey",
                                text: "...",
                                color: .a1,
                                progress: 1
                            )
                            .padding(.horizontal, 18)
                            Text("Syncing with Flipper...")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.black40)
                        }
                        Divider()
                    }
                case .finished:
                    VStack(spacing: 18) {
                        Text("New Keys Collected: \(viewModel.newKeys.count)")
                            .font(.system(size: 18, weight: .bold))
                        VStack(spacing: 24) {
                            Image(
                                viewModel.newKeys.isEmpty
                                ? "FlipperShrugging"
                                : "FlipperSuccess"
                            )
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(.blackBlack20)
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 92)

                            Button {
                                dismiss()
                            } label: {
                                Text("Done")
                                    .roundedButtonStyle(maxWidth: .infinity)
                            }
                            .padding(.horizontal, 10)

                            VStack(spacing: 8) {
                                if !viewModel.newKeys.isEmpty {
                                    Text("Keys have been added to User Dict.")
                                        .font(.system(
                                            size: 14,
                                            weight: .medium))
                                }

                                ForEach(
                                    [MFKey64](viewModel.newKeys),
                                    id: \.self
                                ) { key in
                                    Text(key.hexValue)
                                        .foregroundColor(.black40)
                                        .font(.system(
                                            size: 12,
                                            weight: .medium))
                                }
                            }
                        }
                    }
                    Divider()
                }
            }

            if !viewModel.isError {
                VStack(alignment: .leading, spacing: 32) {
                    CalculatedKeys(results: viewModel.results)
                    if viewModel.hasNewKeys {
                        UniqueKeys(keys: viewModel.newKeys)
                    }
                    if viewModel.hasDuplicatedKeys {
                        DuplicatedKeys(
                            flipperKeys: viewModel.flipperDuplicatedKeys,
                            userKeys: viewModel.userDuplicatedKeys)
                    }
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 18)
    }

    var body: some View {
        ZStack {
            VStack {
                ScrollView {
                    content
                    Spacer()
                }

                if viewModel.state != .finished {
                    HStack {
                        Spacer()
                        Button {
                            viewModel.isAttackInProgress
                                ? viewModel.showCancelAttack = true
                                : dismiss()
                        } label: {
                            Text(viewModel.isError ? "Close" : "Cancel")
                                .font(.system(size: 16, weight: .medium))
                                .padding(.horizontal, 8)
                                .tappableFrame()
                        }
                        Spacer()
                    }
                }
            }

            if alertController.isPresented {
                alertController.alert
            }
        }
        .background(Color.background)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .customAlert(isPresented: $viewModel.showCancelAttack) {
            CancelAttackAlert(isPresented: $viewModel.showCancelAttack) {
                dismiss()
            }
        }
        .environmentObject(alertController)
        .onAppear {
            viewModel.start()
        }
        .onDisappear {
            viewModel.stop()
        }
    }
}

extension ReaderLog.KeyType {
    var color: Color {
        switch self {
        case .a: return .sGreenUpdate
        case .b: return .a2
        }
    }
}
