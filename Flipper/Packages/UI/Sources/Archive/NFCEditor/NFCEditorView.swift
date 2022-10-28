import Core
import SwiftUI

struct NFCEditorView: View {
    @StateObject var viewModel: NFCEditorViewModel
    @StateObject var alertController: AlertController = .init()
    @Environment(\.dismiss) private var dismiss

    @StateObject var hexKeyboardController: HexKeyboardController = .init()

    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    Header(
                        title: "Edit Dump",
                        description: viewModel.item.wrappedValue.name.value,
                        onCancel: {
                            viewModel.cancel()
                        },
                        onSave: {
                            viewModel.save()
                        },
                        onSaveAs: {
                            viewModel.saveAs()
                        }
                    )
                    .simultaneousGesture(TapGesture().onEnded {
                        hexKeyboardController.onKey(.ok)
                    })

                    GeometryReader { proxy in
                        ScrollView {
                            VStack(spacing: 24) {
                                NFCCard(item: viewModel.item)

                                HexEditor(
                                    bytes: $viewModel.bytes,
                                    width: proxy.size.width - 33
                                )
                            }
                            .padding(.top, 14)
                        }
                    }

                    NavigationLink("", isActive: $viewModel.showSaveAs) {
                        SaveAsView(viewModel: .init(
                            item: viewModel.item,
                            dismissPublisher: viewModel.dismissPublisher
                        ))
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
                .customAlert(isPresented: $viewModel.showSaveChanges) {
                    SaveChangesAlert(viewModel: viewModel)
                }
                .environmentObject(alertController)
                .environmentObject(hexKeyboardController)
                .onReceive(viewModel.dismissPublisher) {
                    dismiss()
                }
                if alertController.isPresented {
                    alertController.alert
                }
            }
        }
    }
}
