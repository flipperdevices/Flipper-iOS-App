import Core
import Combine
import Inject
import SwiftUI

class MainViewModel: ObservableObject {
    @AppStorage(.selectedTabKey) var selectedTab: CustomTabView.Tab = .device
    @Published var isTabViewHidden = false

    @Inject var central: BluetoothCentral

    init() {
        central.startScanForPeripherals()
        central.stopScanForPeripherals()
    }
}
