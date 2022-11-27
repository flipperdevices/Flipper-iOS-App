import Core
import SwiftUI

struct NFCToolsView: View {
    @StateObject var viewModel: NFCToolsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack {
                Button {
                    viewModel.showReaderAttackView = true
                } label: {
                    ReaderAttackCard(hasNotification: viewModel.hasMFLog)
                }
            }
            .padding(14)
        }
        .background(Color.background)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LeadingToolbarItems {
                BackButton {
                    dismiss()
                }
                Title("NFC Tools")
            }
        }
        .fullScreenCover(isPresented: $viewModel.showReaderAttackView) {
            ReaderAttackView(viewModel: .init())
        }
    }
}
