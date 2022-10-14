import Core
import SwiftUI

struct NFCEditorView: View {
    @StateObject var viewModel: NFCEditorViewModel
    @StateObject var alertController: AlertController = .init()
    @Environment(\.presentationMode) private var presentationMode

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
                    presentationMode.wrappedValue.dismiss()
                }
                if alertController.isPresented {
                    alertController.alert
                }
            }
        }
    }
}

// MARK: NFC Card

extension NFCEditorView {
    struct NFCCard: View {
        @Binding var item: ArchiveItem

        var mifareType: String {
            guard let typeProperty = item.properties.first(
                where: { $0.key == "Mifare Classic type" }
            ) else {
                return "??"
            }
            return typeProperty.value
        }

        // FIXME: buggy padding

        var paddingLeading: Double {
            switch UIScreen.main.bounds.width {
            case 320: return 3
            case 414: return 24
            default: return 12
            }
        }

        var paddingTrailing: Double {
            switch UIScreen.main.bounds.width {
            case 320: return 4
            case 414: return 34
            default: return 17
            }
        }

        var body: some View {
            ZStack {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 4) {
                        Text("MIFARE Classic \(mifareType)")
                            .font(.system(size: 12, weight: .heavy))

                        Image("NFCCardWaves")
                            .frame(width: 24, height: 24)
                    }
                    .padding(.top, 17)

                    Image("NFCCardInfo")
                        .resizable()
                        .scaledToFit()
                        .padding(.top, 31)

                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text("UID:")
                                .fontWeight(.bold)
                            Text(item.properties["UID"] ?? "")
                                .fontWeight(.medium)
                        }

                        HStack(spacing: 23) {
                            HStack {
                                Text("ATQA:")
                                    .fontWeight(.bold)
                                Text(item.properties["ATQA"] ?? "")
                                    .fontWeight(.medium)
                            }

                            HStack {
                                Text("SAK:")
                                    .fontWeight(.bold)
                                Text(item.properties["SAK"] ?? "")
                                    .fontWeight(.medium)
                            }
                        }
                    }
                    .font(.system(size: 10))
                    .padding(.top, 32)
                    .padding(.bottom, 13)
                }
                .padding(.leading, paddingLeading)
                .padding(.trailing, paddingTrailing)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .background(
                Image("NFCCard")
                    .resizable()
                    .scaledToFit()
            )
        }
    }
}

// MARK: Header

extension NFCEditorView {
    struct Header: View {
        let title: String
        let description: String?
        let onCancel: () -> Void
        let onSave: () -> Void
        let onSaveAs: () -> Void

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

                VStack(spacing: 0) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                    if let description = description {
                        Text(description)
                            .font(.system(size: 12, weight: .medium))
                    }
                }

                Spacer()

                Menu {
                    Button("Save", action: onSave)
                    Button("Save Dump as...", action: onSaveAs)
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

// MARK: Save Changes Alert

extension NFCEditorView {
    struct SaveChangesAlert: View {
        let viewModel: NFCEditorViewModel

        var body: some View {
            VStack(spacing: 24) {
                VStack(spacing: 4) {
                    Text("Save Changes?")
                        .font(.system(size: 14, weight: .bold))
                        .padding(.top, 5)

                    Text("All unsaved changes will be lost")
                        .font(.system(size: 14, weight: .medium))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black40)
                        .padding(.horizontal, 12)
                }

                VStack(spacing: 14) {
                    Divider()
                    Button {
                        viewModel.save()
                    } label: {
                        Text("Save")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.a2)
                    }

                    Divider()
                    Button {
                        viewModel.dismiss()
                    } label: {
                        Text("Don't save")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.primary)
                    }

                    Divider()
                    Button {
                        viewModel.saveAs()
                    } label: {
                        Text("Save Dump As...")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
}
