import SwiftUI

// swiftlint:disable multiline_arguments

struct EchoView: View {
    @StateObject var viewModel: EchoViewModel
    @State var entered: String = ""

    var body: some View {
        VStack {
            TextField("Input", text: $entered) { isEditing in
                viewModel.isEditing = isEditing
            } onCommit: {
                viewModel.send(entered)
                entered = ""
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.gray, lineWidth: 1)
            ).padding()

            List(viewModel.received) {
                Text($0.text)
            }
        }
        .navigationTitle("Echo Server")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct EchoView_Previews: PreviewProvider {
    static var previews: some View {
        EchoView(viewModel: .init())
    }
}
