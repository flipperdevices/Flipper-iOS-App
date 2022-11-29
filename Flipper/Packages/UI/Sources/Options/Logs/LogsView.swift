import Core
import Logging
import SwiftUI

struct LogsView: View {
    @EnvironmentObject var loggerService: LoggerService
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            ForEach(loggerService.logs, id: \.self) { name in
                NavigationLink(name) {
                    NamedLogsView(name: name)
                }
            }
            .onDelete { indexSet in
                loggerService.delete(at: indexSet)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LeadingToolbarItems {
                BackButton {
                    dismiss()
                }
                Title("Logs")
            }
            TrailingToolbarItems {
                NavBarMenu {
                    ForEach(loggerService.logLevels, id: \.self) { level in
                        Button {
                            loggerService.logLevel = level
                        } label: {
                            HStack {
                                Text(level.rawValue)
                                if level == loggerService.logLevel {
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
                    loggerService.deleteAll()
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
