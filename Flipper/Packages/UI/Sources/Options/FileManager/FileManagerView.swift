import Core
import Peripheral

import SwiftUI

struct FileManagerView: View {
    // next step
    @ObservedObject var fileManager = Dependencies.shared.fileManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            FileManagerListing(path: "/")
                .environmentObject(fileManager)
        }
    }
}
