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

                    switch viewModel.item.fileType {
                    case .nfc, .rfid, .ibutton:
                        EmulateButton(viewModel: viewModel)
                    case .subghz:
                        SendButton(viewModel: viewModel)
                    default:
                        EmptyView()
                    }

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
        .onDisappear {
            viewModel.stopApp()
        }
    }
}

struct EmulateButton: View {
    @ObservedObject var viewModel: InfoViewModel

    var body: some View {
        Button {
            if viewModel.isEmulating {
                viewModel.stopEmulate()
            } else {
                viewModel.emulate()
            }
        } label: {
            VStack(spacing: 4) {
                HStack(spacing: 7) {
                    Spacer()
                    Image("Emulate")
                    if viewModel.isEmulating {
                        Image("TextEmulating")
                            .padding(.top, 4)
                    } else {
                        Image("TextEmulate")
                            .padding(.bottom, 2)
                    }
                    Spacer()
                }
                .frame(height: 48)
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .background {
                    if !viewModel.isConnected {
                        Color.black8
                    } else if viewModel.isEmulating {
                        AnimatedPlaceholder(
                            color1: .init(red: 0.65, green: 0.82, blue: 1.0, opacity: 1.0),
                            color2: .init(red: 0.35, green: 0.62, blue: 1.0, opacity: 1.0)
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        Color.a2
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(viewModel.isConnected ? Color.a2 : .black8, lineWidth: 2))
                .disabled(!viewModel.isConnected)
                .opacity(viewModel.isEditing ? 0 : 1)
                .padding(.horizontal, viewModel.isEmulating ? 18 : 24)
                .padding(.top, 18)
                Text("Emulating on Flipper... Tap to stop")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.black20)
                    .opacity(viewModel.isEmulating ? 1 : 0)
            }
        }
    }
}

struct SendButton: View {
    @ObservedObject var viewModel: InfoViewModel

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 7) {
                Spacer()
                Image("Send")
                Image("TextSend")
                Spacer()
            }
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .background {
                if !viewModel.isConnected {
                    Color.black8
                } else if viewModel.isEmulating {
                    AnimatedPlaceholder(
                        color1: .init(red: 1.0, green: 0.71, blue: 0.0, opacity: 1.0),
                        color2: .init(red: 1.0, green: 0.51, blue: 0.0, opacity: 1.0)
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Color.a1
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(viewModel.isConnected ? Color.a1 : .black8, lineWidth: 2))
            .disabled(!viewModel.isConnected)
            .opacity(viewModel.isEditing ? 0 : 1)
            .padding(.horizontal, viewModel.isEmulating ? 18 : 24)
            .padding(.top, 18)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        viewModel.emulate()
                    }
                    .onEnded { _ in
                        viewModel.stopEmulate()
                    })
            Text("Hold to send from Flipper")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.black20)
                .opacity(viewModel.isEmulating ? 0 : 1)
        }
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
