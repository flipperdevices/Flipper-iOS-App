import SwiftUI

extension ReaderAttackView {
    struct Progress: View {
        @StateObject var viewModel: DeviceUpdateViewModel

        var image: String {
            switch viewModel.state {
            case .downloadingFirmware: return "DownloadingUpdate"
            default: return "UploadingUpdate"
            }
        }

        var text: String {
            viewModel.state == .preparingForUpdate
                ? "..."
                : "\(Int(viewModel.progress * 100))%"
        }

        var color: Color {
            switch viewModel.state {
            case .downloadingFirmware: return .sGreenUpdate
            case .preparingForUpdate, .uploadingFirmware, .canceling: return .a2
            default: return .clear
            }
        }

        var body: some View {
            ProgressBarView(
                image: image,
                text: text,
                color: color,
                progress: viewModel.progress)
        }
    }
}
