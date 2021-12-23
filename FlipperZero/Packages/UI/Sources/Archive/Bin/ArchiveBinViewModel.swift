import Core
import Combine
import Inject
import SwiftUI

@MainActor
class ArchiveBinViewModel: ObservableObject {
    @Inject var pairedDevice: PairedDevice
    @Published var archive: Archive = .shared

    var items: [ArchiveItem] {
        archive.items.filter { $0.status == .deleted }
    }

    @Published var device: Peripheral? {
        didSet { status = .init(device?.state) }
    }
    @Published var status: Status = .noDevice

    @Published var isActionPresented = false
    @Published var selectedItem: ArchiveItem = .none

    var disposeBag: DisposeBag = .init()

    init() {
        pairedDevice.peripheral
            .receive(on: DispatchQueue.main)
            .sink { [weak self] item in
                self?.device = item
            }
            .store(in: &disposeBag)

        archive.$isSynchronizing
            .receive(on: DispatchQueue.main)
            .sink { isSynchronizing in
                self.status = isSynchronizing
                    ? .synchronizing
                    : .init(self.device?.state)
            }
            .store(in: &disposeBag)
    }

    func synchronize() {
        guard status == .connected else { return }
        Task {
            await archive.syncWithDevice()
        }
    }

    func deleteSelectedItems() {
        guard selectedItem != .none else {
            return
        }
        archive.wipe(selectedItem)
    }

    func restoreSelectedItems() {
        guard selectedItem != .none else {
            return
        }
        archive.restore(selectedItem)
        synchronize()
    }
}
