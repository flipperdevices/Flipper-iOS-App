import SwiftUI

struct HubChevron: View {
    let hasNotification: Bool

    init(hasNotification: Bool = false) {
        self.hasNotification = hasNotification
    }

    var body: some View {
        HStack(spacing: 2) {
            if hasNotification {
                Circle()
                    .frame(width: 14, height: 14)
                    .foregroundColor(.a1)
            }

            Image("ChevronRight")
                .resizable()
                .frame(width: 14, height: 14)
        }
    }
}
