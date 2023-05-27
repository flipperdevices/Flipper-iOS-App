import Core
import Peripheral

import SwiftUI

struct FileManagerView: View {
    // next step
    @ObservedObject var fileManager: RemoteFileManager = .init(
        pairedDevice: Dependencies.shared.pairedDevice
    )
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            FileManagerListing(path: "/")
                .environmentObject(fileManager)
        }
    }
}
