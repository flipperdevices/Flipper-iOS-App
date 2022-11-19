import SwiftUI

struct NamedLogsView: View {
    @StateObject var viewModel: NamedLogsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            ForEach(viewModel.messages, id: \.self) { message in
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
                Title(viewModel.name)
            }
            TrailingToolbarItems {
                ShareButton {
                    viewModel.share()
                }
            }
        }
    }
}
