import Core
import Inject
import Logging
import Analytics
import Peripheral
import Foundation

@MainActor
class FileManagerViewModel: ObservableObject {
    private let logger = Logger(label: "file-manager-vm")

    @Inject private var rpc: RPC
    @Inject var analytics: Analytics

    @Published var content: Content? {
        didSet {
            if case .file(let text) = content {
                self.text = text
            }
        }
    }
    @Published var text: String = ""
    @Published var name: String = ""
    @Published var isFileImporterPresented = false

    var supportedExtensions: [String] = [
        ".ibtn", ".nfc", ".shd", ".sub", ".rfid", ".ir", ".fmf", ".txt", "log"
    ]

    enum Content {
        case list([Element])
        case file(String)
        case create(isDirectory: Bool)
        case forceDelete(Path)
        case error(String)
    }

    enum PathMode {
        case list
        case edit
        case error
    }

    let path: Path
    let mode: PathMode

    var title: String {
        path.string
    }

    convenience init() {
        self.init(path: .init(string: "/"), mode: .list)
    }

    init(path: Path, mode: PathMode) {
        self.path = path
        self.mode = mode
        recordFileManager()
    }

    func showProgressView() {
        self.content = nil
    }

    func update() {
        Task {
            showProgressView()
            switch self.mode {
            case .list: await listDirectory()
            case .edit: await readFile()
            default: break
            }
        }
    }

    // MARK: Directory

    private func listDirectory() async {
        do {
            let items = try await rpc.listDirectory(at: path)
            self.content = .list(items)
        } catch {
            logger.error("list directory: \(error)")
            self.content = .error(String(describing: error))
        }
    }

    // MARK: File

    func canRead(_ file: File) -> Bool {
        supportedExtensions.contains {
            file.name.hasSuffix($0)
        }
    }

    private func readFile() async {
        do {
            let bytes = try await rpc.readFile(at: path)
            self.content = .file(.init(decoding: bytes, as: UTF8.self))
        } catch {
            logger.error("read file: \(error)")
            self.content = .error(String(describing: error))
        }
    }

    func save() {
        Task {
            do {
                showProgressView()
                try await rpc.writeFile(at: path, string: text)
                self.content = .file(text)
            } catch {
                logger.error("save file: \(error)")
                self.content = .error(String(describing: error))
            }
        }
    }

    // MARK: Import

    func showFileImporter() {
        /*
            File picker won't be shown if hidden by a swipe down
            instead of the Cancel button, so we use this workaround.
            Apple knows about this but so hopefully it'll be fixed soon.
            UPD: Fixed in iOS16
        */
        if isFileImporterPresented {
            isFileImporterPresented = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.isFileImporterPresented = true
            }
        } else {
            isFileImporterPresented = true
        }
    }

    func importFile(url: URL) {
        Task {
            do {
                guard let name = url.pathComponents.last else {
                    logger.error("import file: invalid url \(url)")
                    return
                }
                guard url.startAccessingSecurityScopedResource() else {
                    logger.error("import file: unable to access \(url)")
                    return
                }
                defer {
                    url.stopAccessingSecurityScopedResource()
                }

                showProgressView()
                let path = path.appending(name)
                let bytes = try [UInt8](Data(contentsOf: url))
                try await rpc.writeFile(at: path, bytes: bytes)
                await listDirectory()
            } catch {
                logger.error("import file: \(error)")
                self.content = .error(String(describing: error))
            }
        }
    }

    // Create

    func newElement(isDirectory: Bool) {
        content = .create(isDirectory: isDirectory)
    }

    func cancel() {
        Task {
            showProgressView()
            await listDirectory()
        }
    }

    func create() {
        Task {
            guard !name.isEmpty else { return }
            guard case .create(let isDirectory) = content else {
                return
            }

            let path = path.appending(name)
            name = ""

            do {
                showProgressView()
                try await rpc.createFile(at: path, isDirectory: isDirectory)
                await listDirectory()
            } catch {
                logger.error("create file: \(error)")
                self.content = .error(String(describing: error))
            }
        }
    }

    // Delete

    func delete(at index: Int) {
        Task {
            guard case .list(var elements) = content else {
                return
            }

            let element = elements.remove(at: index)
            self.content = .list(elements)
            let elementPath = path.appending(element.name)

            do {
                try await rpc.deleteFile(at: elementPath, force: false)
                self.content = .list(elements)
            } catch let error as Peripheral.Error where error == .storage(.notEmpty) {
                self.content = .forceDelete(elementPath)
            } catch {
                logger.error("delete file: \(error)")
                self.content = .error(String(describing: error))
            }
        }
    }

    func forceDelete() {
        Task {
            guard case .forceDelete(let path) = content else {
                return
            }
            do {
                showProgressView()
                try await rpc.deleteFile(at: path, force: true)
                await listDirectory()
            } catch {
                logger.error("force delete: \(error)")
                self.content = .error(String(describing: error))
            }
        }
    }

    // Analytics

    func recordFileManager() {
        analytics.appOpen(target: .fileManager)
    }
}
