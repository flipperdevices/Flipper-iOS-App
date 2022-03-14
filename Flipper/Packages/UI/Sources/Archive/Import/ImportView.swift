import SwiftUI

struct ImportView: View {
    @StateObject var viewModel: ImportViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isEditMode {
                SheetEditHeader(
                    "Edit Key",
                    onSave: viewModel.saveChanges,
                    onCancel: viewModel.undoChanges
                )
            } else {
                SheetHeader("Add Key") {
                    presentationMode.wrappedValue.dismiss()
                }
            }

            CardView(
                item: $viewModel.item,
                isEditing: viewModel.isEditMode,
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
                    if viewModel.add() {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .padding(.top, 18)
            .padding(.horizontal, 60)
            .opacity(viewModel.isEditMode ? 0 : 1)

            Spacer()
        }
        .background(Color.background)
        .edgesIgnoringSafeArea(.bottom)
    }
}
