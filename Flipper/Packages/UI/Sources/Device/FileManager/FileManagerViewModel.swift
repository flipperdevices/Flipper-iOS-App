import Core
import Combine
import Inject

import struct Foundation.Date

@MainActor
class FileManagerViewModel: ObservableObject {
    private let rpc: RPC = .shared

    @Published var content: Content? {
        didSet {
            if case .file(let text) = content {
                self.text = text
            }
        }
    }
    @Published var text: String = ""
    @Published var name: String = ""

    var supportedExtensions: [String] = [
        ".ibtn", ".nfc", ".sub", ".rfid", ".ir", ".txt"
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
    }

    func update() async {
        switch self.mode {
        case .list: await listDirectory()
        case .edit: await readFile()
        default: break
        }
    }

    // MARK: Directory

    func listDirectory() async {
        content = nil
        do {
            let items = try await rpc.listDirectory(at: path)
            self.content = .list(items)
        } catch {
            self.content = .error(String(describing: error))
        }
    }

    // MARK: File

    func canRead(_ file: File) -> Bool {
        supportedExtensions.contains {
            file.name.hasSuffix($0)
        }
    }

    func readFile() async {
        do {
            let bytes = try await rpc.readFile(at: path)
            self.content = .file(.init(decoding: bytes, as: UTF8.self))
        } catch {
            self.content = .error(String(describing: error))
        }
    }

    func save() {
        Task {
            let text = text
            self.content = nil
            do {
                try await rpc.writeFile(at: path, string: text)
                self.content = .file(text)
            } catch {
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
            await listDirectory()
        }
    }

    func create() {
        Task {
            guard !name.isEmpty else { return }
            guard case .create(let isDirectory) = content else {
                return
            }

            content = nil

            let path = path.appending(name)
            name = ""

            do {
                try await rpc.createFile(at: path, isDirectory: isDirectory)
                await listDirectory()
            } catch {
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
            } catch let error as Core.Error where error == .storage(.notEmpty) {
                self.content = .forceDelete(elementPath)
            } catch {
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
                try await rpc.deleteFile(at: path, force: true)
                await listDirectory()
            } catch {
                self.content = .error(String(describing: error))
            }
        }
    }
}
