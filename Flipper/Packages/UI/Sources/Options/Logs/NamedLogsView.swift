import SwiftUI

struct NamedLogsView: View {
    @StateObject var viewModel: NamedLogsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            ForEach(viewModel.messages, id: \.self) { message in
                Text(message)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton {
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Text(viewModel.name)
                    .font(.system(size: 20, weight: .bold))
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.share()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .foregroundColor(.primary)
            }
        }
    }
}
