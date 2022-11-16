import Core
import SwiftUI

struct ReaderAttackView: View {
    @StateObject var viewModel: ReaderAttackViewModel
    @StateObject var alertController: AlertController = .init()
    @Environment(\.dismiss) private var dismiss

    var title: String {
        guard !viewModel.newKeys.isEmpty else {
            return "New Keys Not Found"
        }
        let keysCount = viewModel.newKeys.count
        let s = keysCount == 1 ? "" : "s"
        return "\(keysCount) New Key\(s) added to User Dict."
    }

    var content: some View {
        VStack(spacing: 18) {
            VStack {
                switch viewModel.state {
                case .noLog:
                    ReaderDataNotFound(fliperColor: viewModel.flipperColor)
                case .noDevice:
                    AttackConnectionError(fliperColor: viewModel.flipperColor)
                case .noSDCard:
                    AttackStorageError(fliperColor: viewModel.flipperColor)
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
                    VStack(spacing: 14) {
                        Text(title)
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

                            if !viewModel.newKeys.isEmpty {
                                KeysView(.init(viewModel.newKeys))
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

            if !viewModel.isError {
                VStack(alignment: .leading, spacing: 32) {
                    CalculatedKeys(
                        results: viewModel.results,
                        showProgress: viewModel.showCalculatedKeysSpinner
                    )
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

extension ReaderAttackView {
    struct KeysView: View {
        let keys: [MFKey64]

        var rows: Range<Int> {
            0 ..< ((keys.count + 1) / 2)
        }

        init(_ keys: [MFKey64]) {
            self.keys = keys
        }

        var body: some View {
            VStack(spacing: 10) {
                ForEach(rows, id: \.self) { row in
                    HStack {
                        if keys.indices.contains(row * 2 + 1) {
                            KeyView(keys[row * 2])
                            Spacer()
                            KeyView(keys[row * 2 + 1])
                        } else {
                            Spacer()
                            KeyView(keys[row * 2])
                            Spacer()
                        }
                    }
                }
            }
        }
    }

    struct KeyView: View {
        let key: MFKey64

        init(_ key: MFKey64) {
            self.key = key
        }

        var body: some View {
            HStack(spacing: 6) {
                Image("FoundKey")
                Text(key.hexValue.uppercased())
                    .foregroundColor(.primary.opacity(0.8))
                    .font(.system(
                        size: 12,
                        weight: .medium,
                        design: .monospaced))
            }
            .padding(.leading, 10)
            .padding(.trailing, 12)
            .padding(.vertical, 12)
            .background(Color.groupedBackground)
            .cornerRadius(30)
        }
    }
}
