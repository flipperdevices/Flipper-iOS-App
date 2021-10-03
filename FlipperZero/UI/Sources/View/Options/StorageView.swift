import SwiftUI

struct StorageView: View {
    @StateObject var viewModel: StorageViewModel

    var body: some View {
        VStack {
            List {
                if !viewModel.path.isEmpty {
                    Button("..") {
                        viewModel.moveUp()
                    }
                }
                ForEach(viewModel.elements, id: \.description) {
                    switch $0 {
                    case .directory(let directory):
                        Button(directory.name) {
                            viewModel.listDirectory(directory.name)
                        }
                    case .file(let file):
                        HStack {
                            Text(file.name)
                            Spacer()
                            Text("\(file.size) bytes")
                        }
                    }
                }
            }
        }
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
