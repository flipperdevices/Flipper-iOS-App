import SwiftUI

struct ImportView: View {
    @StateObject var viewModel: ImportViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isEditing {
                SheetEditHeader(
                    title: "Edit Key",
                    onSave: viewModel.saveChanges,
                    onCancel: viewModel.undoChanges
                )
            } else {
                SheetHeader(title: "Add Key") {
                    viewModel.dismiss()
                }
            }

            CardView(
                item: $viewModel.item,
                isEditing: $viewModel.isEditing,
                kind: .imported
            )
            .padding(.top, 14)
            .padding(.horizontal, 24)

            HStack {
                Button("Edit") {
                    viewModel.edit()
                }
                .foregroundColor(.black30)
                .font(.system(size: 14, weight: .bold))
                Spacer()
                RoundedButton("Add") {
                    viewModel.add()
                }
            }
            .padding(.top, 18)
            .padding(.horizontal, 60)
            .opacity(viewModel.isEditing ? 0 : 1)

            Spacer()
        }
        .alert(isPresented: $viewModel.isError) {
            Alert(title: Text(viewModel.error))
        }
        .onReceive(viewModel.dismissPublisher) {
            dismiss()
        }
        .background(Color.background)
        .edgesIgnoringSafeArea(.bottom)
    }
}
