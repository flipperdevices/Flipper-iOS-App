import SwiftUI

struct SaveAsView: View {
    @StateObject var viewModel: SaveAsViewModel
    @StateObject var alertController: AlertController = .init()
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                ZStack {
                    HStack {
                        BackButton {
                            presentationMode.wrappedValue.dismiss()
                        }
                        Spacer()
                    }

                    HStack {
                        Spacer()
                        Text("Save Dump as..")
                            .font(.system(size: 18, weight: .bold))
                        Spacer()
                    }

                    HStack {
                        Spacer()
                        Button {
                            viewModel.save()
                        } label: {
                            Text("Save")
                                .foregroundColor(.primary)
                                .font(.system(size: 14, weight: .medium))
                        }
                        .frame(width: 66)
                    }
                }
                .padding(.horizontal, 11)
                .padding(.top, 17)
                .padding(.bottom, 6)

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        CardView(
                            item: viewModel.item,
                            isEditing: .init(get: { true }, set: { _ in }),
                            kind: .existing
                        )
                        .padding(.top, 14)
                        .padding(.horizontal, 24)

                        Spacer()
                    }
                }
            }

            if alertController.isPresented {
                alertController.alert
            }
        }
        .navigationBarHidden(true)
        .alert(isPresented: $viewModel.isError) {
            Alert(title: Text(viewModel.error))
        }
        .background(Color.background)
        .edgesIgnoringSafeArea(.bottom)
    }
}
