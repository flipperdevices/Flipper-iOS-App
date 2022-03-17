import Core
import SwiftUI

extension ArchiveItem.Status {
    var image: AnyView {
        switch self {
        case .synchronizing: return .init(Image("Syncing"))
        case .synchronized: return .init(Image("Synced"))
        default: return .init(Image("NotSynced"))
        }
    }
}
