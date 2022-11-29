import Core
import SwiftUI

struct NFCToolsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State var hasMFLog = false
    @State var showReaderAttackView = false

    var body: some View {
        ScrollView {
            VStack {
                Button {
                    showReaderAttackView = true
                } label: {
                    ReaderAttackCard(hasNotification: hasMFLog)
                }
            }
            .padding(14)
        }
        .background(Color.background)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LeadingToolbarItems {
                BackButton {
                    dismiss()
                }
                Title("NFC Tools")
            }
        }
        .fullScreenCover(isPresented: $showReaderAttackView) {
            ReaderAttackView()
        }
        .onChange(of: appState.hasMFLog) {
            self.hasMFLog = $0
        }
    }
}
