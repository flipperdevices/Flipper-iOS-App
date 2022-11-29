import Core
import SwiftUI

struct NamedLogsView: View {
    @EnvironmentObject var loggerService: LoggerService
    @Environment(\.dismiss) private var dismiss

    let name: String
    @State var messages: [String] = []

    var body: some View {
        List {
            ForEach(messages, id: \.self) { message in
                Text(message)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LeadingToolbarItems {
                BackButton {
                    dismiss()
                }
                Title(name)
            }
            TrailingToolbarItems {
                ShareButton {
                    shareLogs(name: name, messages: messages)
                }
            }
        }
        .task {
            messages = loggerService.read(name)
        }
    }
}
