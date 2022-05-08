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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.deleteAll()
                } label: {
                    Text("Delete all")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.primary)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
