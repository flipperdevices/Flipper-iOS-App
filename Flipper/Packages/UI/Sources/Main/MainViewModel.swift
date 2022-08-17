import Core
import Inject
import Peripheral
import Combine
import SwiftUI

@MainActor
class MainViewModel: ObservableObject {
    @AppStorage(.selectedTabKey) var selectedTab: TabView.Tab = .device
    @Published var status: DeviceStatus = .noDevice
    @Published var syncProgress: Int = 0

    @Published var importedName = ""
    @Published var importedOpacity = 0.0

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

        appState.imported
            .receive(on: DispatchQueue.main)
            .sink { [weak self] item in
                self?.onItemAdded(item: item)
            }
            .store(in: &disposeBag)

        appState.$syncProgress
            .receive(on: DispatchQueue.main)
            .assign(to: \.syncProgress, on: self)
            .store(in: &disposeBag)
    }

    func onItemAdded(item: ArchiveItem) {
        importedName = item.name.value
        Task { @MainActor in
            try await Task.sleep(milliseconds: 200)
            withAnimation { importedOpacity = 1.0 }
            try await Task.sleep(seconds: 3)
            withAnimation { importedOpacity = 0 }
        }
    }
}
