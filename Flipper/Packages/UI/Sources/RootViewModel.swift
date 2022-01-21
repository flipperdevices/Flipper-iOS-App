import Core
import Combine
import Inject
import Logging
import SwiftUI

public class RootViewModel: ObservableObject {
    private let logger = Logger(label: "root")

    let appState: AppState = .shared

    // MARK: First Launch

    @Published var presentWelcomeSheet = false

    var isFirstLaunch: Bool {
        get { appState.isFirstLaunch }
        set { appState.isFirstLaunch = newValue }
    }

    // MARK: Full Application

    @AppStorage(.selectedTabKey) var selectedTab: CustomTabView.Tab = .device
    @Published var isTabViewHidden = false

    @Inject var connector: BluetoothConnector
    private var disposeBag: DisposeBag = .init()

    public init() {
        presentWelcomeSheet = isFirstLaunch

        connector.connectedPeripherals
            .sink { [weak self] in
                self?.device = $0.first
            }
            .store(in: &disposeBag)
    }

    var device: BluetoothPeripheral?
    let archive: Archive = .shared

    enum Error: String, Swift.Error {
        case invalidURL = "invalid url"
        case invalidData = "invalid data"
        case cantOpenDoc = "error opening doc"
    }

    func importKey(_ keyURL: URL) async {
        do {
            switch keyURL.scheme {
            case "file": try await importFile(keyURL)
            case "flipper": try await importURL(keyURL)
            default: break
            }
            logger.info("key imported")
        } catch {
            logger.critical("\(error)")
        }
    }

    func importURL(_ url: URL) async throws {
        guard let name = url.host, let content = url.pathComponents.last else {
            throw Error.invalidURL
        }
        guard let data = Data(base64Encoded: content) else {
            throw Error.invalidData
        }
        await importKey(name: name, data: data)
    }

    func importFile(_ url: URL) async throws {
        let name = url.lastPathComponent

        switch try? Data(contentsOf: url) {
        // internal file
        case .some(let data):
            try? FileManager.default.removeItem(at: url)
            logger.debug("importing internal key: \(name)")
            await importKey(name: name, data: data)
        // icloud file
        case .none:
            let doc = await KeyDocument(fileURL: url)
            guard await doc.open(), let data = await doc.data else {
                throw Error.cantOpenDoc
            }
            logger.debug("importing icloud key: \(name)")
            await importKey(name: name, data: data)
        }
    }

    func importKey(name: String, data: Data) async {
        let content = String(decoding: data, as: UTF8.self)

        guard let item = ArchiveItem(
            fileName: name,
            content: content,
            status: .imported
        ) else {
            logger.error("importing error, invalid data")
            return
        }

        archive.importKey(item)
        await archive.syncWithDevice()
    }
}
