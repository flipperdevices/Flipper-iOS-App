import SwiftUI

struct LogsView: View {
    @StateObject var viewModel: LogsViewModel
    @Environment(\.presentationMode) private var presentationMode

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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LeadingToolbarItems {
                BackButton {
                    presentationMode.wrappedValue.dismiss()
                }
                Title("Logs")
            }
            TrailingToolbarItems {
                NavBarMenu {
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
                        .padding(.horizontal, 4)
                }

                NavBarButton {
                    viewModel.deleteAll()
                } label: {
                    Text("Delete All")
                        .font(.system(size: 14, weight: .bold))
                        .padding(.horizontal, 4)
                }
                .padding(.trailing, 4)
            }
        }
    }
}
