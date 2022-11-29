import Core
import SwiftUI

struct HubView: View {
    @EnvironmentObject var appState: AppState
    @State var hasMFLog = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    NavigationLink {
                        NFCToolsView()
                    } label: {
                        NFCToolsCard(hasNotification: hasMFLog)
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
        .onChange(of: appState.hasMFLog) {
            self.hasMFLog = $0
        }
    }
}
