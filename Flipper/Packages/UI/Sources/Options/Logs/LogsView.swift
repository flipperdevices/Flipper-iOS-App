import Core

import Logging
import SwiftUI

struct LogsView: View {
    // next step
    @StateObject var logs: Logs = .init(
        loggerStorage: Dependencies.shared.loggerStorage
    )
    @Environment(\.dismiss) private var dismiss

    @AppStorage(.logLevelKey) var logLevel: Logger.Level = .debug

    public var logLevels: [Logger.Level] {
        Logger.Level.allCases
    }

    var body: some View {
        List {
            ForEach(logs.records, id: \.self) { name in
                NavigationLink(name) {
                    LogView(name: name)
                        .environmentObject(logs)
                }
            }
            .onDelete { indexSet in
                logs.delete(indexSet)
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
                    ForEach(logLevels, id: \.self) { level in
                        Button {
                            logLevel = level
                        } label: {
                            HStack {
                                Text(level.rawValue)
                                if level == logLevel {
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
                    logs.deleteAll()
                } label: {
                    Text("Delete All")
                        .font(.system(size: 14, weight: .bold))
                        .padding(.horizontal, 4)
                }
                .padding(.trailing, 4)
            }
        }
        .task { @MainActor in
            logs.reload()
        }
    }
}
