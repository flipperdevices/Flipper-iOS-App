import SwiftUI

struct HubChevron: View {
    let hasNotification: Bool

    init(hasNotification: Bool = false) {
        self.hasNotification = hasNotification
    }

    var body: some View {
        HStack(spacing: 2) {
            Circle()
                .frame(width: 14, height: 14)
                .foregroundColor(.a1)
                .opacity(hasNotification ? 1 : 0)

            Image("ChevronRight")
                .resizable()
                .frame(width: 14, height: 14)
        }
    }
}
