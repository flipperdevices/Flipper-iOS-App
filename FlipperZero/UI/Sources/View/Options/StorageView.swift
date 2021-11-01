import Core
import SwiftUI

struct StorageView: View {
    @StateObject var viewModel: StorageViewModel

    var body: some View {
        VStack {
            switch viewModel.content {
            case .list(let elements): listView(with: elements)
            case .file: editorView()
            case .name: nameView()
            case .error(let error): Text(error)
            case .none: ProgressView()
            }
        }
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !viewModel.path.isEmpty, case .list = viewModel.content {
                Menu {
                    Button {
                        viewModel.newElement(isDirectory: false)
                    } label: {
                        Text("File")
                    }

                    Button {
                        viewModel.newElement(isDirectory: true)
                    } label: {
                        Text("Folder")
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }

    func listView(with elements: [Element]) -> some View {
        List {
            if !viewModel.path.isEmpty {
                Button("..") {
                    viewModel.moveUp()
                }
            }
            if !elements.isEmpty {
                list(with: elements)
            }
        }
    }

    func list(with elements: [Element]) -> some View {
        ForEach(elements, id: \.description) {
            switch $0 {
            case .directory(let directory):
                Button(directory.name) {
                    viewModel.listDirectory(directory.name)
                }
            case .file(let file):
                if let data = file.data, !data.isEmpty {
                    Text(String(decoding: data, as: UTF8.self))
                } else {
                    if viewModel.canRead(file) {
                        Button {
                            viewModel.readFile(file)
                        } label: {
                            FileRow(file: file)
                        }
                    } else {
                        FileRow(file: file)
                    }
                }
            }
        }
        .onDelete { indexSet in
            if let index = indexSet.first {
                viewModel.delete(at: index)
            }
        }
    }

    func editorView() -> some View {
        VStack {
            TextEditor(text: $viewModel.text)
                .padding(.top, 5)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.secondary, lineWidth: 1))

            HStack {
                RoundedButton("Close") {
                    viewModel.moveUp()
                }

                RoundedButton("Save") {
                    viewModel.save()
                }
            }
        }
        .padding(.bottom, 16)
    }

    func nameView() -> some View {
        VStack {
            TextField("Name", text: $viewModel.name)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.gray, lineWidth: 1))
                .padding()

            HStack {
                RoundedButton("Cancel", action: viewModel.cancel)
                RoundedButton("Create", action: viewModel.create)
            }
        }
        .padding(16)
    }
}

struct FileRow: View {
    let file: File

    var body: some View {
        HStack {
            Text(file.name)
            Spacer()
            Text("\(file.size) bytes")
        }
    }
}
