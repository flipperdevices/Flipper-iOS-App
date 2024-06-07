import Core
import Peripheral

import SwiftUI

struct FileManagerView: View {
    // next step
    @StateObject var fileManager = Dependencies.shared.fileManager

    enum Destination: Hashable {
        case listing(Peripheral.Path)
        case editor(Peripheral.Path)
    }

    var body: some View {
        FileManagerListing(path: "/")
            .environmentObject(fileManager)
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case .listing(let path):
                    FileManagerListing(path: path)
                        .environmentObject(fileManager)
                case .editor(let path):
                    FileManagerEditor(path: path)
                        .environmentObject(fileManager)
                }
            }
    }
}
