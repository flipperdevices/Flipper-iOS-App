import Core
import Peripheral

import SwiftUI
import UniformTypeIdentifiers

struct FileManagerListing: View {
    let path: Peripheral.Path

    @EnvironmentObject var fileManager: RemoteFileManager
    @Environment(\.dismiss) var dismiss

    @State var elements: [Element] = []
    @State var error: String? = nil
    @State var isBusy = false

    @State var name = ""
    @State var isNewFile = false
    @State var isNewDirectory = false
    @FocusState var isNameFocused: Bool
    var namePlaceholder: String {
        "\(isNewFile ? "file" : "directory") name"
    }

    @State var isFileImporterPresented = false

    var body: some View {
        VStack {
            if isBusy {
                ProgressView()
            } else if let error = error {
                Text(error)
            } else {
                List {
                    if !path.isEmpty {
                        Button("..") {
                            dismiss()
                        }
                        .foregroundColor(.primary)
                    }
                    if isNewFile || isNewDirectory {
                        TextField(namePlaceholder, text: $name)
                            .onSubmit {
                                submitNewElement()
                            }
                            .focused($isNameFocused)
                    }
                    ForEach(elements, id: \.description) {
                        switch $0 {
                        case .directory(let directory):
                            HStack {
                                Image(systemName: "folder.fill")
                                    .frame(width: 20)

                                NavigationLink(directory.name) {
                                    FileManagerListing(
                                        path: path.appending(directory.name)
                                    )
                                    .environmentObject(fileManager)
                                }
                                .foregroundColor(.primary)
                            }
                        case .file(let file):
                            if let data = file.data, !data.isEmpty {
                                Text(String(decoding: data, as: UTF8.self))
                            } else {
                                HStack {
                                    if fileManager.canRead(file) {
                                        Image(systemName: "doc")
                                            .frame(width: 20)
                                        NavigationLink {
                                            FileManagerEditor(
                                                path: path.appending(file.name)
                                            )
                                            .environmentObject(fileManager)
                                        } label: {
                                            FileRow(file: file)
                                        }
                                        .foregroundColor(.primary)
                                    } else {
                                        Image(systemName: "lock.doc")
                                            .frame(width: 20)
                                        FileRow(file: file)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                    .onDelete { indexSet in
                        delete(indexSet)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LeadingToolbarItems {
                BackButton {
                    dismiss()
                }
                Title(path.lastComponent ?? "/")
            }
            TrailingToolbarItems {
                if !path.isEmpty {
                    NavBarMenu {
                        Button {
                            newElement(isDirectory: false)
                        } label: {
                            Text("File")
                        }

                        Button {
                            newElement(isDirectory: true)
                        } label: {
                            Text("Folder")
                        }

                        Button {
                            isFileImporterPresented = true
                        } label: {
                            Text("Import")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .fileImporter(
            isPresented: $isFileImporterPresented,
            allowedContentTypes: [UTType.item]
        ) { result in
            if case .success(let url) = result {
                importFile(url)
            }
        }
        .task {
            await list()
        }
    }

    func showingProgress(_ task: () async throws -> Void) async throws {
        isBusy = true
        defer { isBusy = false }
        try await task()
    }

    func list() async {
        do {
            try await showingProgress {
                elements = try await fileManager.list(at: path)
            }
        } catch {
            self.error = String(describing: error)
        }
    }

    func delete(_ indexSet: IndexSet) {
        Task {
            for index in indexSet {
                let element = elements.remove(at: index)
                do {
                    try await fileManager.delete(element, at: path)
                } catch let error as RemoteFileManager.Error
                            where error == .directoryIsNotEmpty {
                    self.error = "directory is not empty"
                } catch {
                    self.error = String(describing: error)
                    elements.insert(element, at: index)
                }
            }
        }
    }

    func newElement(isDirectory: Bool) {
        name = ""
        isNewFile = !isDirectory
        isNewDirectory = isDirectory
        isNameFocused = true
    }

    func submitNewElement() {
        if !name.isEmpty {
            let path = path.appending(name)
            let isDirectory = isNewDirectory
            Task {
                do {
                    try await fileManager.create(
                        path: path,
                        isDirectory: isDirectory)
                    await list()
                } catch {
                    self.error = String(describing: error)
                }
            }
        }
        name = ""
        isNewFile = false
        isNewDirectory = false
    }

    func importFile(_ url: URL) {
        Task {
            do {
                try await showingProgress {
                    try await fileManager.importFile(url: url, at: path)
                }
                await list()
            } catch {
                self.error = String(describing: error)
            }
        }
    }
}

extension FileManagerListing {
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
}
