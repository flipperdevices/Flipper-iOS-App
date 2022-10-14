import SwiftUI

struct ImportView: View {
    @StateObject var viewModel: ImportViewModel
    @Environment(\.presentationMode) private var presentationMode

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

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    CardView(
                        item: $viewModel.item,
                        isEditing: $viewModel.isEditing,
                        kind: .imported
                    )
                    .padding(.top, 6)
                    .padding(.horizontal, 24)

                    Button {
                        viewModel.add()
                    } label: {
                        Text("Save to Archive")
                            .roundedButtonStyle(maxWidth: .infinity)
                    }
                    .padding(.top, 18)
                    .padding(.horizontal, 24)
                    .opacity(viewModel.isEditing ? 0 : 1)

                    Spacer()
                }
            }
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
