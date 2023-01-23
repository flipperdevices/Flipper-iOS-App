import Core
import SwiftUI

struct LogView: View {
    @EnvironmentObject var logs: Logs
    @Environment(\.dismiss) private var dismiss

    let name: String
    @State var messages: [Message] = []

    public struct Message: Identifiable {
        public let id: UUID
        public let text: String

        init(_ text: String) {
            self.id = .init()
            self.text = text
        }
    }

    var body: some View {
        List {
            ForEach(messages) { message in
                Text(message.text)
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
                    shareLogs(name: name, messages: messages.map { $0.text })
                }
            }
        }
        .task {
            messages = logs.read(name).map { .init($0) }
        }
    }
}