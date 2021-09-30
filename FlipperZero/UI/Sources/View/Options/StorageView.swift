import SwiftUI

struct StorageView: View {
    @StateObject var viewModel: StorageViewModel
    @State var directory: String = "nfc" {
        didSet {
            directory = directory.filter { $0.isLetter }
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            List(viewModel.elements, id: \.description) {
                Text($0.description)
            }

            TextField("dir name", text: $directory)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.gray, lineWidth: 1)
                ).padding()

            RoundedButton("request /ext/\(directory) listing") {
                viewModel.sendListRequest(for: directory)
            }
            .padding(.bottom, 100)
        }
        .navigationTitle("Storage list")
        .navigationBarTitleDisplayMode(.inline)
    }
}
