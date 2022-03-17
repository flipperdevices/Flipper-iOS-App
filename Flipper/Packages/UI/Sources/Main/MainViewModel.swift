import Core
import Combine
import Inject
import SwiftUI

class MainViewModel: ObservableObject {
    @AppStorage(.selectedTabKey) var selectedTab: TabView.Tab = .device
    @Published var status: Status = .noDevice

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
            .sink { [weak self] item in
                self?.onItemAdded(item: item)
            }
            .store(in: &disposeBag)
    }

    func onItemAdded(item: ArchiveItem) {
        importedName = item.name.value
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
            withAnimation {
                self.importedOpacity = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                withAnimation {
                    self.importedOpacity = 0
                }
            }
        }
    }
}
