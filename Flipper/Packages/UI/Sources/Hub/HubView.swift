import Core
import SwiftUI

struct HubView: View {
    @AppStorage(.hasReaderLog) var hasReaderLog = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    NavigationLink {
                        NFCToolsView()
                    } label: {
                        NFCToolsCard(hasNotification: hasReaderLog)
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
