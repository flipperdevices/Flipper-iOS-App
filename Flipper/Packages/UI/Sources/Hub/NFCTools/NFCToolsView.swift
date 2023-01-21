import Core
import SwiftUI

struct NFCToolsView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var showReaderAttackView = false
    @AppStorage(.hasReaderLog) var hasReaderLog = false

    var body: some View {
        ScrollView {
            VStack {
                Button {
                    showReaderAttackView = true
                } label: {
                    ReaderAttackCard(hasNotification: hasReaderLog)
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
    }
}
