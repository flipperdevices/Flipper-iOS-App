import Core
import Peripheral

import SwiftUI
import UniformTypeIdentifiers

extension FileManagerView {
    struct FileManagerListing: View {
        @Environment(\.path) var navigationPath

        let path: Peripheral.Path

        @EnvironmentObject var fileManager: RemoteFileManager
        @Environment(\.dismiss) var dismiss

        @State private var elements: [Element] = []
        @State private var error: String?
        @State private var isBusy = false

        @State private var name = ""
        @State private var isNewFile = false
        @State private var isNewDirectory = false
        @FocusState var isNameFocused: Bool
        var namePlaceholder: String {
            "\(isNewFile ? "file" : "directory") name"
        }

        @State private var selectedIndexSet: IndexSet?
        @State private var isForceDeletePresented = false
        @State private var isFileImporterPresented = false

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
                                NavigationLink(value: Destination.listing(
                                    path.appending(directory.name)
                                )) {
                                    DirectoryRow(directory: directory)
                                }
                                .foregroundColor(.primary)
                            case .file(let file):
                                HStack {
                                    FileRow(file: file)
                                        .onTapGesture {
                                            navigationPath.append(
                                                Destination.editor(
                                                    path.appending(file.name)
                                                )
                                            )
                                        }
                                    DownloadFileIcon()
                                        .onTapGesture {
                                            Task {
                                                await downloadFile(file)
                                            }
                                        }
                                }
                            }
                        }
                        .onDelete { indexSet in
                            Task {
                                await delete(indexSet)
                            }
                        }
                    }
                }
            }
            .navigationBarBackground(Color.a1)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                LeadingToolbarItems {
                    BackButton {
                        dismiss()
                    }
                }
                PrincipalToolbarItems(alignment: .leading) {
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
            .alert(
                "Directory is not empty",
                isPresented: $isForceDeletePresented,
                presenting: selectedIndexSet
            ) { selectedIndexSet in
                Button("Force Delete", role: .destructive) {
                    Task {
                        await delete(selectedIndexSet, force: true)
                    }
                }
            }
            .fileImporter(
                isPresented: $isFileImporterPresented,
                allowedContentTypes: [UTType.item]
            ) { result in
                if case .success(let url) = result {
                    Task {
                        await importFile(url)
                    }
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

        func delete(_ indexSet: IndexSet, force: Bool = false) async {
            guard let index = indexSet.first else { return }
            let element = elements.remove(at: index)
            do {
                try await fileManager.delete(element, at: path, force: force)
            } catch let error as RemoteFileManager.Error
                        where error == .directoryIsNotEmpty && !force {
                elements.insert(element, at: index)
                self.selectedIndexSet = indexSet
                self.isForceDeletePresented = true
            } catch {
                self.error = String(describing: error)
                elements.insert(element, at: index)
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

        func importFile(_ url: URL) async {
            do {
                try await showingProgress {
                    try await fileManager.importFile(url: url, at: path)
                }
                await list()
            } catch {
                self.error = String(describing: error)
            }
        }

        func downloadFile(_ file: File) async {
            isBusy = true
            defer { isBusy = false }
            do {
                let bytes = try await fileManager.readRaw(
                    at: path.appending(file.name))
                let url = try FileManager.default.createTempFile(
                    name: file.name,
                    data: .init(bytes))
                share(url) {
                    try? FileManager.default.removeItem(at: url)
                }
            } catch {
                self.error = String(describing: error)
            }
        }
    }
}

extension FileManagerView.FileManagerListing {
    struct DirectoryRow: View {
        let directory: Directory

        var body: some View {
            HStack {
                Image(systemName: "folder.fill")
                    .frame(width: 20)

                Text(directory.name)
            }
        }
    }

    struct FileRow: View {
        let file: File

        var body: some View {
            HStack {
                Image(systemName: "doc")
                    .frame(width: 20)
                Text(file.name)
                Spacer()
                Text("\(file.size) bytes")
            }
            .contentShape(Rectangle())
        }
    }

    struct DownloadFileIcon: View {
        var body: some View {
            Image(systemName: "icloud.and.arrow.down")
                .frame(width: 20, height: 20)
        }
    }
}
