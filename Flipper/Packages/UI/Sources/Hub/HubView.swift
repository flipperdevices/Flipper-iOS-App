import Core
import SwiftUI

struct HubView: View {
    @StateObject var viewModel: HubViewModel

    var body: some View {
        NavigationView {
            List {
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Hub")
                        .font(.system(size: 20, weight: .bold))
                }
            }
        }
        .navigationViewStyle(.stack)
        .navigationBarColors(foreground: .primary, background: .a1)
    }
}
