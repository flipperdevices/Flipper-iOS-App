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
    let achive: Archive = .shared

    func importKey(_ keyURL: URL) {
        let name = keyURL.lastPathComponent

        func completion(_ result: Result<Void, Error>) {
            switch result {
            case .success:
                print("key \(name) imported")
            case .failure(let error):
                print(error)
            }
        }

        switch try? Data(contentsOf: keyURL) {
        // internal file
        case .some(let data):
            try? FileManager.default.removeItem(at: keyURL)
            print("importing internal key", name)
            achive.importKey(
                name: name,
                data: .init(data),
                completion: completion)
        // icloud file
        case .none:
            let doc = KeyDocument(fileURL: keyURL)
            doc.open { [weak self] success in
                guard success, let data = doc.data else {
                    print("error opening doc")
                    return
                }
                print("importing icloud key", name)
                self?.achive.importKey(
                    name: name,
                    data: .init(data),
                    completion: completion)
            }
        }
    }
}
