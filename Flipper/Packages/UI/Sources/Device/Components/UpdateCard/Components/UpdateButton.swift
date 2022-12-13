import Core
import SwiftUI

struct UpdateButton: View {
    let state: VersionUpdateModel.State.Ready
    var action: () -> Void

    var title: String {
        switch state {
        case .noUpdates: return "NO UPDATES"
        case .versionUpdate: return "UPDATE"
        case .channelUpdate: return "INSTALL"
        }
    }

    var color: Color {
        switch state {
        case .noUpdates: return .black20
        case .versionUpdate: return .sGreenUpdate
        case .channelUpdate: return .a1
        }
    }

    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                Spacer()
                Text(title)
                    .foregroundColor(.white)
                    .font(.born2bSportyV2(size: 40))
                Spacer()
            }
            .frame(height: 46)
            .frame(maxWidth: .infinity)
            .background(color)
            .cornerRadius(9)
            .padding(.horizontal, 12)
            .padding(.top, 12)
        }
        // .disabled(viewModel.state == .noUpdates)
    }
}
