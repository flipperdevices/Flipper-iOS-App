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
    }
}
