import Core
import Combine
import Inject
import SwiftUI

class MainViewModel: ObservableObject {
    @AppStorage(.selectedTabKey) var selectedTab: TabView.Tab = .device
    @Published var status: Status = .noDevice

    @Inject var central: BluetoothCentral

    let appState: AppState = .shared
    var disposeBag: DisposeBag = .init()

    init() {
        central.startScanForPeripherals()
        central.stopScanForPeripherals()

        appState.$status
            .receive(on: DispatchQueue.main)
            .assign(to: \.status, on: self)
            .store(in: &disposeBag)
    }
}
