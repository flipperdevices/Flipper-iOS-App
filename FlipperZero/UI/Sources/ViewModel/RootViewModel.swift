import Core
import Combine
import Injector
import Foundation

public class RootViewModel: ObservableObject {

    // MARK: First Launch

    @Published var presentWelcomeSheet = false

    var isFirstLaunch: Bool {
        get { UserDefaultsStorage.shared.isFirstLaunch }
        set { UserDefaultsStorage.shared.isFirstLaunch = newValue }
    }

    // MARK: Full Application

    @Published var selectedTab: CustomTabView.Tab = .archive
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

    func importKey(_ keyURL: URL) {
        func completion(_ result: Result<Void, Error>) {
            switch result {
            case .success:
                print("key imported")
            case .failure(let error):
                print(error)
            }
        }

        switch keyURL.scheme {
        case "file": importFile(keyURL, completion: completion)
        case "flipper": importURL(keyURL, completion: completion)
        default: break
        }
    }

    func importURL(
        _ url: URL,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let name = url.host, let content = url.pathComponents.last else {
            print("invalid url")
            return
        }
        guard let data = Data(base64Encoded: content) else {
            print("invalid data")
            return
        }

        archive.importKey(name: name, data: .init(data))
        archive.syncWithDevice()
    }

    func importFile(
        _ url: URL,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let name = url.lastPathComponent

        switch try? Data(contentsOf: url) {
        // internal file
        case .some(let data):
            try? FileManager.default.removeItem(at: url)
            print("importing internal key", name)
            archive.importKey(name: name, data: .init(data))
            archive.syncWithDevice()
        // icloud file
        case .none:
            let doc = KeyDocument(fileURL: url)
            doc.open { [weak self] success in
                guard success, let data = doc.data else {
                    print("error opening doc")
                    return
                }
                print("importing icloud key", name)
                self?.archive.importKey(name: name, data: .init(data))
                self?.archive.syncWithDevice()
            }
        }
    }
}
