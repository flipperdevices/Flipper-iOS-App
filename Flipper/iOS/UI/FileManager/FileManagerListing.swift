import Core
import UniformTypeIdentifiers
import Peripheral

import SwiftUI

extension FileManagerView {
    struct FileManagerListing: View {
        @EnvironmentObject var fileManager: RemoteFileManager
        @EnvironmentObject var device: Device

        @Environment(\.path) var navigationPath
        @Environment(\.dismiss) var dismiss

        @State private var _elements: [ExtendedElement] = []
        @State private var isLoading = true
        @State private var error: String?

        @State private var isFileImporterPresented = false
        @State private var showOptions = false
        @State private var selectedElement: ExtendedElement?

        @AppStorage(.fileManagerSettings)
        private var settings: FileManagerSettings = .init()

        let path: Peripheral.Path

        private var title: String {
            path.isRoot ? "File Manager" : path.lastComponent ?? "/"
        }

        var elements: [ExtendedElement] {
            settings.isHiddenFilesShow
                ? _elements
                : _elements.filter { !$0.name.hasPrefix(".") }
        }

        var body: some View {
            VStack {
                if let error = error {
                    Text(error)
                } else if isLoading {
                    ProgressView()
                } else {
                    List {
                        if path.isRoot {
                            SDCardInfo(device.storageInfo?.external)
                        } else {
                            NavigationPathView(path: path)
                        }

                        if elements.isEmpty {
                            EmptyFolder(onUpload: showUpload)
                        } else {
                            FileManagerElements(
                                elements: elements,
                                displayType: settings.displayType,
                                onTap: navigate,
                                onDelete: deleteFile,
                                onAction: { selectedElement = $0 }
                            )
                        }
                    }
                    .listRowSpacing(12)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
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
                    Title(title)
                }

                TrailingToolbarItems {
                    EllipsisButton {
                        showOptions = true
                    }
                    .disabled(isLoading || error != nil)
                }
            }
            .popup(isPresented: $showOptions) {
                FileListingOptions(
                    isPresented: $showOptions,
                    settings: $settings,
                    upload: showUpload
                )
            }
            .sheet(item: $selectedElement) {
                SelectedElementSheet(
                    element: $0,
                    onExport: downloadFile,
                    onDelete: deleteFile
                )
            }
            .fileImporter(
                isPresented: $isFileImporterPresented,
                allowedContentTypes: [UTType.item],
                allowsMultipleSelection: true
            ) { result in
                switch result {
                case .success(let urls):
                    importFiles(urls)
                case .failure(let error):
                    self.error = String(describing: error)
                }
            }
            .task { await load() }
            .refreshable { await load() }
        }

        private func load() async {
            isLoading = true
            defer { isLoading = false }

            do {
                _elements = try await fileManager.list(at: path)
            } catch {
                self.error = String(describing: error)
            }
        }

        private func navigate(_ extended: ExtendedElement) {
            switch extended.type {
            case .directory(let directory):
                let nextPath = path.appending(directory.name)
                navigationPath.append(Destination.listing(nextPath))
            case .file(let file):
                let nextPath = path.appending(file.name)
                navigationPath.append(Destination.editor(nextPath))
            }
        }

        private func importFiles(_ urls: [URL]) {
            isLoading = true
            defer { isLoading = false }

            Task {
                do {
                    try await urls.forEach { url in
                        try await fileManager.importFile(url: url, at: path)
                    }
                    await load()
                } catch {
                    self.error = String(describing: error)
                }
            }
        }

        private func downloadFile(_ extended: ExtendedElement) {
            isLoading = true
            defer { isLoading = false }

            guard case let .file(file) = extended.type else { return }

            Task {
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

        private func deleteFile(_ extended: ExtendedElement) {
            isLoading = true
            defer { isLoading = false }

            Task {
                do {
                    try await fileManager.delete(extended.type, at: path)
                    await load()
                } catch {
                    self.error = String(describing: error)
                }
            }
        }

        private func showUpload() {
            isFileImporterPresented = true
        }
    }
}

fileprivate extension Peripheral.Path {
    var isRoot: Bool {
        self == "/ext"
    }
}
