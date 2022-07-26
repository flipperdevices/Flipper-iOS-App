import SwiftUI

struct NFCEditorView: View {
    @StateObject var viewModel: NFCEditorViewModel
    @Environment(\.dismiss) var dismiss

    @StateObject var hexKeyboardController: HexKeyboardController = .init()

    var body: some View {
        VStack(spacing: 0) {
            Header(
                title: "Edit Dump",
                description: viewModel.item.name.value,
                onCancel: { dismiss() },
                onSave: { viewModel.save() }
            )

            GeometryReader { proxy in
                ScrollView {
                    VStack(spacing: 24) {
                        HexEditor(
                            bytes: viewModel.bytes,
                            width: proxy.size.width - 33
                        )
                    }
                    .padding(.top, 14)
                }
            }

            if !hexKeyboardController.isHidden {
                HexKeyboard(
                    onButton: { hexKeyboardController.onKey(.hex($0)) },
                    onBack: { hexKeyboardController.onKey(.back) },
                    onOK: { hexKeyboardController.onKey(.ok) }
                )
                .transition(.move(edge: .bottom))
            }
        }
        .navigationBarHidden(true)
        .environmentObject(hexKeyboardController)
    }
}

extension NFCEditorView {
    struct Header: View {
        let title: String
        let description: String?
        let onCancel: () -> Void
        let onSave: () -> Void

        var body: some View {
            HStack {
                Button {
                    onCancel()
                } label: {
                    Text("Close")
                        .foregroundColor(.primary)
                        .font(.system(size: 14, weight: .medium))
                }

                Spacer()

                VStack {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                    if let description = description {
                        Text(description)
                            .font(.system(size: 12, weight: .medium))
                    }
                }

                Spacer()

                Button {
                    onSave()
                } label: {
                    Text(" Save")
                        .foregroundColor(.primary)
                        .font(.system(size: 14, weight: .medium))
                }
            }
            .padding(.horizontal, 19)
            .padding(.top, 17)
            .padding(.bottom, 6)
        }
    }
}
