import Core
import Combine
import Injector

import struct Foundation.Date

class StorageViewModel: ObservableObject {
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
        case name(isDirectory: Bool)
        case forceDelete(Path)
        case error(String)
    }

    var root: [Element] = [.directory("int"), .directory("ext")]
    var path: Path = .init()

    var title: String {
        path.isEmpty
            ? "Storage browser"
            : requestTime == nil
                ? path.string
                // swiftlint:disable force_unwrapping
                : path.string + " - \(requestTime!.kindaRounded)s"
    }

    private let rpc: RPC = .shared

    init() {
        content = .list(root)
    }

    // MARK: Directory

    func moveUp() {
        guard !path.isEmpty else {
            return
        }
        path.removeLastComponent()
        if path.isEmpty {
            content = .list(root)
        } else {
            listDirectory()
        }
    }

    func enter(directory name: String) {
        path.append(name)
        listDirectory()
    }

    func listDirectory() {
        content = nil
        rpc.listDirectory(at: path) { result in
            switch result {
            case .success(let items):
                self.content = .list(items)
            case .failure(let error):
                self.content = .error(error.description)
            }
        }
    }

    // MARK: File

    func canRead(_ file: File) -> Bool {
        supportedExtensions.contains {
            file.name.hasSuffix($0)
        }
    }

    func readFile(_ file: File) {
        content = nil
        path.append(file.name)
        rpc.readFile(at: path) { result in
            switch result {
            case .success(let bytes):
                self.content = .file(.init(decoding: bytes, as: UTF8.self))
            case .failure(let error):
                self.content = .error(error.description)
            }
        }
    }

    // Temporary
    var startTime: Date = .init()
    var requestTime: Double?

    func save() {
        let text = text
        self.content = nil
        startTime = .init()
        rpc.writeFile(at: path, string: text) { result in
            switch result {
            case .success:
                self.content = .file(text)
            case .failure(let error):
                self.content = .error(error.description)
            }
        }
    }

    // Create

    func newElement(isDirectory: Bool) {
        content = .name(isDirectory: isDirectory)
    }

    func cancel() {
        listDirectory()
    }

    func create() {
        guard !name.isEmpty else { return }
        guard case .name(let isDirectory) = content else {
            return
        }

        content = nil

        let path = path.appending(name)
        name = ""

        // swiftlint:disable multiline_arguments opening_brace
        rpc.createFile(at: path, isDirectory: isDirectory)
        { result in
            switch result {
            case .success: self.listDirectory()
            case .failure(let error): self.content = .error(error.description)
            }
        }
    }

    // Delete

    func delete(at index: Int) {
        guard case .list(var elements) = content else {
            return
        }

        let element = elements.remove(at: index)
        self.content = .list(elements)
        let elementPath = path.appending(element.name)

        rpc.deleteFile(at: elementPath, force: false) { result in
            switch result {
            case .success:
                self.content = .list(elements)
            case .failure(let error) where error == .storage(.notEmpty):
                self.content = .forceDelete(elementPath)
            case .failure(let error):
                self.content = .error(error.description)
            }
        }
    }

    func forceDelete() {
        guard case .forceDelete(let path) = content else {
            return
        }
        rpc.deleteFile(at: path, force: true) { result in
            switch result {
            case .success:
                self.listDirectory()
            case .failure(let error):
                self.content = .error(error.description)
            }
        }
    }
}

extension Double {
    var kindaRounded: Double {
        (self * 100).rounded() / 100
    }
}
