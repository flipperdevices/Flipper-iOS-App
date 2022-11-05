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
                        NFCToolsCard(hasNotification: viewModel.hasMFLog)
                    }
                }
                .padding(14)
            }
            .background(Color.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                LeadingToolbarItems {
                    Title("Hub")
                        .padding(.leading, 8)
                }
            }
        }
        .navigationViewStyle(.stack)
        .navigationBarColors(foreground: .primary, background: .a1)
    }
}
