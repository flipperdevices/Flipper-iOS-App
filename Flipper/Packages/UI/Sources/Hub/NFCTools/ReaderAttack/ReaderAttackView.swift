import Core
import SwiftUI

struct ReaderAttackView: View {
    @StateObject var viewModel: ReaderAttackViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack {
                    switch viewModel.state {
                    case .noLog:
                        HStack {
                            Spacer()
                            Text("No reader log found")
                                .font(.system(size: 18, weight: .bold))
                                .offset(y: proxy.size.height / 2)
                            Spacer()
                        }
                    case .downloadingLog:
                        VStack(spacing: 18) {
                            Text("Calculation Started...")
                                .font(.system(size: 18, weight: .bold))
                            VStack(spacing: 8) {
                                ProgressBarView(
                                    image: "ProgressDownload",
                                    text: viewModel.progressString,
                                    color: .a2,
                                    progress: viewModel.progress)
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
                                    progress: viewModel.progress)
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
                                    progress: 1)
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
                                    progress: 1)
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
                                Image("FlipperSuccess")
                                    .renderingMode(.template)
                                    .foregroundColor(.blackBlack20)

                                RoundedButton("Done") {
                                    dismiss()
                                }

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

                if viewModel.state != .noLog {
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
                    .padding(.top, 18)
                }
            }
        }
        .padding(14)
        .background(Color.background)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton {
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Text("Mfkey32 (Detect Reader)")
                    .font(.system(size: 20, weight: .bold))
            }
        }
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
