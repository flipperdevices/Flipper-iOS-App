import SwiftUI

struct InfoView: View {
    @StateObject var viewModel: InfoViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if viewModel.isEditing {
                SheetEditHeader(
                    "Editing",
                    onSave: viewModel.saveChanges,
                    onCancel: viewModel.undoChanges
                )
                .padding(.bottom, 6)
            } else {
                SheetHeader(viewModel.isNFC ? "Card Info" : "Key Info") {
                    viewModel.dismiss()
                }
                .padding(.bottom, 6)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    CardView(
                        item: $viewModel.item,
                        isEditing: $viewModel.isEditing,
                        kind: .existing
                    )
                    .padding(.top, 14)
                    .padding(.horizontal, 24)

                    Button {
                        viewModel.emulate()
                    } label: {
                        HStack(spacing: 7) {
                            Spacer()
                            Image("Emulate")
                            Text("Emulate")
                            Spacer()
                        }
                        .frame(height: 47)
                        .frame(maxWidth: .infinity)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .background(viewModel.isConnected ? Color.a2 : .gray)
                        .cornerRadius(30)
                    }
                    .disabled(!viewModel.isConnected)
                    .opacity(viewModel.isEditing ? 0 : 1)
                    .padding(.horizontal, 24)
                    .padding(.top, 18)

                    VStack(alignment: .leading, spacing: 20) {
                        if viewModel.isEditableNFC {
                            InfoButton(image: "HexEditor", title: "Edit Dump") {
                                viewModel.showDumpEditor = true
                            }
                            .foregroundColor(.primary)
                        }
                        InfoButton(image: "Share", title: "Share") {
                            viewModel.share()
                        }
                        .foregroundColor(.primary)
                        InfoButton(image: "Delete", title: "Delete") {
                            viewModel.delete()
                        }
                        .foregroundColor(.sRed)
                    }
                    .padding(.top, 24)
                    .padding(.horizontal, 24)
                    .opacity(viewModel.isEditing ? 0 : 1)

                    Spacer()
                }
            }
        }
        .fullScreenCover(isPresented: $viewModel.showDumpEditor) {
            NFCEditorView(viewModel: .init(item: viewModel.item))
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

struct InfoButton: View {
    let image: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(image)
                    .renderingMode(.template)
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
        }
    }
}
