import SwiftUI

struct ImportView: View {
    @StateObject var viewModel: ImportViewModel
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme

    var backgroundColor: Color {
        colorScheme == .dark
            ? .backgroundDark
            : .backgroundLight
    }

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

            ImportCardView(item: viewModel.item)
                .padding(.top, 14)
                .padding(.horizontal, 24)

            Button {
                viewModel.save()
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Save")
                    .frame(height: 41)
                    .padding(.horizontal, 38)
                    .foregroundColor(.white)
                    .background(Color.accentColor)
                    .font(.system(size: 14, weight: .bold))
                    .cornerRadius(30)
            }
            .padding(.top, 18)

            Spacer()
        }
        .background(backgroundColor)
        .edgesIgnoringSafeArea(.bottom)
        .onDisappear {
            viewModel.cancel()
        }
    }
}
