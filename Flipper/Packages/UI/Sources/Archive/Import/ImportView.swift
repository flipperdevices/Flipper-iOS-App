import SwiftUI

struct ImportView: View {
    @StateObject var viewModel: ImportViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text("Add Key")
                    .font(.system(size: 18, weight: .bold))
                Spacer()
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.primary)
            }
            .padding(.horizontal, 18)
            .padding(.top, 17)
            .padding(.bottom, 6)

            CardView(item: viewModel.item)
                .padding(.top, 14)
                .padding(.horizontal, 24)

            RoundedButton("Save") {
                viewModel.save()
                presentationMode.wrappedValue.dismiss()
            }
            .padding(.top, 18)

            Spacer()
        }
        .background(Color.background)
        .edgesIgnoringSafeArea(.bottom)
        .onDisappear {
            viewModel.cancel()
        }
    }
}
