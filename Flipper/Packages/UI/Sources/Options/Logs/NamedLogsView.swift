import SwiftUI

struct NamedLogsView: View {
    @StateObject var viewModel: NamedLogsViewModel

    var body: some View {
        List {
            ForEach(viewModel.messages, id: \.self) { message in
                Text(message)
            }
        }
        .navigationTitle(viewModel.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.share()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .foregroundColor(.primary)
            }
        }
        .navigationTitle(viewModel.name)
    }
}
