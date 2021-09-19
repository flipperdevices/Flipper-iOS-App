import SwiftUI

// swiftlint:disable multiline_arguments

struct EchoView: View {
    @StateObject var viewModel: EchoViewModel
    @State var entered: String = ""

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Log")) {
                    List(viewModel.received) {
                        Text($0.text)
                    }.frame(maxHeight: .infinity)
                }
            }
            Form {
                TextField("Input", text: $entered) { isEditing in
                    viewModel.isEditing = isEditing
                } onCommit: {
                    viewModel.send(entered)
                    entered = ""
                }
            }
        }
    }
}

struct EchoView_Previews: PreviewProvider {
    static var previews: some View {
        EchoView(viewModel: .init())
    }
}
