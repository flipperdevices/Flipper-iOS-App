import Core
import Inject
import Combine
import Peripheral
import Foundation
import SwiftUI

@MainActor
class DeviceUpdateViewModel: ObservableObject {
    private let appState: AppState = .shared
    private var disposeBag: DisposeBag = .init()

    @Published var flipper: Flipper?

    var isConnected: Bool {
        flipper?.state == .connected
    }

    enum Channel: String {
        case development
        case canditate
        case release
    }

    enum State {
        case noUpdates
        case versionUpdate
        case channelUpdate
        case downloadingFirmware
        case uploadingFirmware
        case updateInProgress
    }

    @AppStorage("update_channel") var channel: Channel = .development {
        didSet { updateAvailableFirmware() }
    }

    @Published var availableFirmware: String = ""

    @Published var state: State = .downloadingFirmware
    @Published var progress: Int = 50

    init() {
        appState.$flipper
            .receive(on: DispatchQueue.main)
            .assign(to: \.flipper, on: self)
            .store(in: &disposeBag)

        updateAvailableFirmware()
    }

    func updateAvailableFirmware() {
    }

    func update() {
    }

    func cancel() {
    }
}
