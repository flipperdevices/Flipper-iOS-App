import Core
import SwiftUI

protocol ActionProtocol: Identifiable {
    var name: String { get }
    var image: Image { get }
}

struct ActionsForm<Action: ActionProtocol>: View {
    let actions: [Action]
    let onActionSelected: (Action.ID) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ForEach(actions) { item in
                if item.id != actions.first?.id {
                    Divider()
                        .padding(0)
                }
                Button {
                    onActionSelected(item.id)
                } label: {
                    ActionRow(action: item)
                }
            }
        }
        .background(systemBackground)
        .foregroundColor(Color.accentColor)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
}

struct ActionRow<Action: ActionProtocol>: View {
    let action: Action

    var body: some View {
        HStack {
            Text(action.name)
                .font(.system(size: 16))
            Spacer()
            action.image
                .font(.system(size: 22))
        }
        .padding(16)
    }
}
