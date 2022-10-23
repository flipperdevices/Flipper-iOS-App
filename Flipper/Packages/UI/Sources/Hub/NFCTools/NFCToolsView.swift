import Core
import SwiftUI

struct NFCToolsView: View {
    @StateObject var viewModel: NFCToolsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack {
                NavigationLink {
                    ReaderAttackView(viewModel: .init())
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
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton {
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Text("NFCTools")
                    .font(.system(size: 20, weight: .bold))
            }
        }
    }
}
