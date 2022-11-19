import SwiftUI

struct ImportView: View {
    @StateObject var viewModel: ImportViewModel
    @Environment(\.dismiss) private var dismiss

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

            switch viewModel.state {
            case .loading:
                VStack {
                    Spacer()
                    Animation("Loading")
                        .frame(width: 48, height: 48)
                    Spacer()
                }
            case .error(.noInternet):
                VStack {
                    Spacer()
                    NoInternetError {
                        viewModel.retry()
                    }
                    Spacer()
                }
            case .error(.cantConnect):
                VStack {
                    Spacer()
                    CantConnectError {
                        viewModel.retry()
                    }
                    Spacer()
                }
            case .imported:
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

    struct NoInternetError: View {
        var action: () -> Void

        var body: some View {
            VStack(spacing: 8) {
                Image("SharingNoInternet")
                    .resizable()
                    .frame(width: 104, height: 60)

                VStack(spacing: 6) {
                    Text("No Internet Connection")
                        .font(.system(size: 14, weight: .medium))
                    Text("Unable to download this key")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black30)
                }

                Button {
                    action()
                } label: {
                    Text("Retry")
                        .font(.system(size: 16, weight: .medium))
                }
                .padding(.top, 4)
            }
        }
    }

    struct CantConnectError: View {
        var action: () -> Void

        var body: some View {
            VStack(spacing: 8) {
                Image("SharingCantConnect")
                    .resizable()
                    .frame(width: 104, height: 60)

                VStack(spacing: 6) {
                    Text("Can't Connect to the Server")
                        .font(.system(size: 14, weight: .medium))
                    Text("Unable to download this key")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black30)
                }

                Button {
                    action()
                } label: {
                    Text("Retry")
                        .font(.system(size: 16, weight: .medium))
                }
                .padding(.top, 4)
            }
        }
    }
}
