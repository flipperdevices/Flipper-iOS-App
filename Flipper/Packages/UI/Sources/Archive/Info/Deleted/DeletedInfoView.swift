import SwiftUI

struct DeletedInfoView: View {
    @StateObject var viewModel: DeletedInfoViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SheetHeader("Key Info") {
                viewModel.dismiss()
            }

            CardView(
                item: $viewModel.item,
                isEditing: $viewModel.isEditing,
                kind: .existing
            )
            .padding(.top, 14)
            .padding(.horizontal, 24)

            VStack(alignment: .leading, spacing: 20) {
                InfoButton(image: .init("Restore"), title: "Restore") {
                    viewModel.restore()
                }
                .foregroundColor(.primary)
                InfoButton(image: .init("Delete"), title: "Delete Permanently") {
                    viewModel.delete()
                }
                .foregroundColor(.sRed)
            }
            .padding(.top, 24)
            .padding(.horizontal, 24)

            Spacer()
        }
        .alert(isPresented: $viewModel.isError) {
            Alert(title: Text(viewModel.error))
        }
        .onReceive(viewModel.dismissPublisher) {
            presentationMode.wrappedValue.dismiss()
        }
        .background(Color.background)
        .edgesIgnoringSafeArea(.bottom)
    }
}
