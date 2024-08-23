import SwiftUI

extension InfraredLayoutView {
    struct InfraredLayoutTitle: View {
        let keyName: String
        let state: InfraredLayoutState

        var body: some View {
            switch state {
            case .default, .emulating:
                Title(keyName, description: "Remote")
            case .disabled:
                CustomTitle(
                    keyName: keyName,
                    description: "Flipper not connected",
                    image: "WarningSmall")
                .foregroundColor(.red)
            case .syncing:
                CustomTitle(
                    keyName: keyName,
                    description: "Syncing...",
                    image: "Syncing")
                .foregroundColor(.a2)
            case .notSupported:
                CustomTitle(
                    keyName: keyName,
                    description: "Not supported emulate",
                    image: "WarningSmall")
                .foregroundColor(.red)
            }
        }
    }

    private struct CustomTitle: View {
        let keyName: String
        let description: String
        let image: String

        var body: some View {
            VStack(spacing: 0) {
                Text(keyName)
                    .lineLimit(1)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)

                HStack(spacing: 4) {
                    Image(image)

                    Text(description)
                        .lineLimit(1)
                        .font(.system(size: 12, weight: .medium))
                }
            }
        }
    }
}
