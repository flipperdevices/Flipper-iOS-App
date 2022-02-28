import Core
import SwiftUI
import Combine

struct ArchiveView: View {
    @StateObject var viewModel: ArchiveViewModel

    var body: some View {
        NavigationView {
            VStack {
                Text("Content")
            }
            .edgesIgnoringSafeArea(.top)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Archive")
                        .font(.system(size: 20, weight: .bold))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18, weight: .bold))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationBarColors(foreground: .primary, background: .orange)
    }
}
