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
                ScrollView {
                    VStack(spacing: 18) {
                        CardPlaceholder()

                        AnimatedPlaceholder()
                            .frame(maxWidth: .infinity)
                            .frame(height: 41)
                            .cornerRadius(30)
                    }
                    .padding(.top, 6)
                    .padding(.horizontal, 24)
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

    struct CardPlaceholder: View {
        @Environment(\.colorScheme) var colorScheme

        var dividerColor: Color {
            colorScheme == .dark ? .black60 : .black4
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 18) {
                AnimatedPlaceholder()
                    .frame(width: 114, height: 44)
                    .cornerRadius(18, corners: [.bottomRight])
                    .offset(x: -4, y: -4)

                VStack(alignment: .leading, spacing: 14) {
                    AnimatedPlaceholder()
                        .frame(width: 128, height: 16)
                    AnimatedPlaceholder()
                        .frame(width: 96, height: 12)
                }
                .padding(.horizontal, 12)

                Divider()
                    .frame(height: 1)
                    .background(dividerColor)

                VStack(alignment: .leading, spacing: 14) {
                    AnimatedPlaceholder()
                        .frame(width: 64, height: 12)
                    AnimatedPlaceholder()
                        .frame(width: 64, height: 12)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 18)
            }
            .background(Color.groupedBackground)
            .cornerRadius(16)
            .shadow(color: .shadow, radius: 16, x: 0, y: 4)
        }
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
