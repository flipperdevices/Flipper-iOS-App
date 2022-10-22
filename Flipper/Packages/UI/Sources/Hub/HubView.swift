import Core
import SwiftUI

struct HubView: View {
    @StateObject var viewModel: HubViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    NavigationLink {
                        NFCToolsView(viewModel: .init())
                    } label: {
                        NFCToolsCard(hasNotification: true)
                    }
                }
                .padding(14)
            }
            .background(Color.background)
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
