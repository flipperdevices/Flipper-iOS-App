import SwiftUI

struct NamedLogsView: View {
    @StateObject var viewModel: NamedLogsViewModel
    @Environment(\.presentationMode) private var presentationMode

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
                    presentationMode.wrappedValue.dismiss()
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
