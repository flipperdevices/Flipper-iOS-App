import SwiftUI

struct LogsView: View {
    @StateObject var viewModel: LogsViewModel

    var body: some View {
        List {
            ForEach(viewModel.logs, id: \.self) { name in
                NavigationLink(name) {
                    NamedLogsView(viewModel: .init(name: name))
                }
            }
            .onDelete { indexSet in
                viewModel.delete(at: indexSet)
            }
        }
        .navigationTitle("Logs")
        .navigationBarTitleDisplayMode(.inline)
    }
}
