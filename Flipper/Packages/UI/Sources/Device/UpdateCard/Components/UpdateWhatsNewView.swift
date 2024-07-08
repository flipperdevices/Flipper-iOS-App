import Core
import SwiftUI

struct UpdateWhatsNewView: View {
    @Environment(\.dismiss) private var dismiss

    let firmware: Update.Firmware
    let state: UpdateModel.State.Ready
    let startUpdate: () -> Void

    var body: some View {
        VStack(spacing: 4) {
            NavBar(
                principal: {
                    VStack(spacing: 0) {
                        Text("What’s New")
                            .font(.system(size: 18, weight: .bold))

                        Text(firmware.version.description)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(firmware.version.color)
                    }
                },
                trailing: {
                    CloseButton { dismiss() }
                }
            )

            ScrollView {
                GitHubMarkdown(firmware.changelog)
                    .padding(.horizontal, 14)
            }

            UpdateButton(state: state) {
                dismiss()
                startUpdate()
            }
            .padding(.bottom, 8)
        }
    }
}
