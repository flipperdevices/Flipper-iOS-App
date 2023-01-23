import Core
import SwiftUI

import enum Peripheral.FlipperColor

struct DetectReaderView: View {
    @EnvironmentObject private var device: Device
    @StateObject private var detectReader: DetectReader = .init()

    @StateObject private var alertController: AlertController = .init()
    @Environment(\.dismiss) private var dismiss

    @State var showCancelAttack = false

    var flipperColor: FlipperColor {
        device.flipper?.color ?? .white
    }

    var title: String {
        guard !detectReader.newKeys.isEmpty else {
            return "New Keys Not Found"
        }
        let keysCount = detectReader.newKeys.count
        let s = keysCount == 1 ? "" : "s"
        return "\(keysCount) New Key\(s) added to User Dict."
    }

    var content: some View {
        VStack(spacing: 18) {
            VStack {
                switch detectReader.state {
                case .noLog:
                    ReaderDataNotFound(fliperColor: flipperColor)
                case .noDevice:
                    AttackConnectionError(fliperColor: flipperColor)
                case .noSDCard:
                    AttackStorageError(fliperColor: flipperColor)
                case .downloadingLog:
                    VStack(spacing: 18) {
                        Text("Calculation Started...")
                            .font(.system(size: 18, weight: .bold))
                        VStack(spacing: 8) {
                            ProgressBarView(
                                color: .a2,
                                image: "ProgressDownload",
                                progress: detectReader.progress
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
                                color: .a1,
                                image: "ProgressKey",
                                progress: detectReader.progress
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
                                color: .a1,
                                image: "ProgressKey",
                                progress: 1,
                                text: "..."
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
                                color: .a1,
                                image: "ProgressKey",
                                progress: 1,
                                text: "..."
                            )
                            .padding(.horizontal, 18)
                            Text("Syncing with Flipper...")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.black40)
                        }
                        Divider()
                    }
                case .finished:
                    VStack(spacing: 14) {
                        Text(title)
                            .font(.system(size: 18, weight: .bold))
                        VStack(spacing: 24) {
                            Image(
                                detectReader.newKeys.isEmpty
                                    ? "FlipperShrugging"
                                    : "FlipperSuccess"
                            )
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(.blackBlack20)
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 92)

                            if !detectReader.newKeys.isEmpty {
                                KeysView(.init(detectReader.newKeys))
                            }

                            Button {
                                dismiss()
                            } label: {
                                Text("Done")
                                    .font(.system(size: 16, weight: .bold))
                                    .roundedButtonStyle(
                                        height: 47,
                                        maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal, 10)

                        Divider()
                    }
                }
            }

            if !detectReader.isError {
                VStack(alignment: .leading, spacing: 32) {
                    CalculatedKeys(
                        results: detectReader.results,
                        showProgress: detectReader.showCalculatedKeysSpinner
                    )
                    if detectReader.hasNewKeys {
                        UniqueKeys(keys: detectReader.newKeys)
                    }
                    if detectReader.hasDuplicatedKeys {
                        DuplicatedKeys(
                            flipperKeys: detectReader.flipperDuplicatedKeys,
                            userKeys: detectReader.userDuplicatedKeys)
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

                if detectReader.state != .finished {
                    HStack {
                        Spacer()
                        Button {
                            detectReader.inProgress
                                ? showCancelAttack = true
                                : dismiss()
                        } label: {
                            Text(detectReader.isError ? "Close" : "Cancel")
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
        .customAlert(isPresented: $showCancelAttack) {
            CancelAttackAlert(isPresented: $showCancelAttack) {
                dismiss()
            }
        }
        .environmentObject(alertController)
        .onAppear {
            detectReader.start()
        }
        .onDisappear {
            detectReader.stop()
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
