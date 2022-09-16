import SwiftUI

struct LogsView: View {
    @StateObject var viewModel: LogsViewModel
    @Environment(\.dismiss) private var dismiss

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
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton {
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Text("Logs")
                    .font(.system(size: 20, weight: .bold))
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    ForEach(viewModel.logLevels, id: \.self) { level in
                        Button {
                            viewModel.changeLogLevel(to: level)
                        } label: {
                            HStack {
                                Text(level.rawValue)
                                if level == viewModel.logLevel {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Text("Log level")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.primary)
                }
            }
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
