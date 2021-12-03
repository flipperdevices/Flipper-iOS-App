import Core
import Combine
import Inject

import struct Foundation.Date

@MainActor
class FileManagerViewModel: ObservableObject {
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
            Task {
                await listDirectory()
            }
        }
    }

    func enter(directory name: String) {
        path.append(name)
        Task {
            await listDirectory()
        }
    }

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

    func readFile(_ file: File) {
        Task {
            content = nil
            path.append(file.name)
            do {
                let bytes = try await rpc.readFile(at: path)
                self.content = .file(.init(decoding: bytes, as: UTF8.self))
            } catch {
                self.content = .error(String(describing: error))
            }
        }
    }

    // Temporary
    var startTime: Date = .init()
    var requestTime: Double?

    func save() {
        Task {
            let text = text
            self.content = nil
            startTime = .init()
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
        content = .name(isDirectory: isDirectory)
    }

    func cancel() {
        Task {
            await listDirectory()
        }
    }

    func create() {
        Task {
            guard !name.isEmpty else { return }
            guard case .name(let isDirectory) = content else {
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

extension Double {
    var kindaRounded: Double {
        (self * 100).rounded() / 100
    }
}
