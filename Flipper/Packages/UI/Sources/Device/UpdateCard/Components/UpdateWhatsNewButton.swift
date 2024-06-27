import Core
import SwiftUI

struct UpdateWhatsNewButton: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var showChangelog: Bool = false

    let updateState: UpdateModel.State
    let updateChannel: Update.Channel
    let firmware: Update.Firmware?
    let startUpdate: () -> Void

    var textColor: Color {
        switch colorScheme {
        case .light: return .black40
        default: return .black30
        }
    }

    var borderColor: Color {
        switch colorScheme {
        case .light: return .black8
        default: return .black80
        }
    }

    var body: some View {
        if
            let firmware = firmware, updateChannel != .custom,
            case .ready(let state) = updateState,
            state == .versionUpdate || state == .channelUpdate
        {
            HStack(spacing: 4) {
                Image("WhatsNew")
                    .resizable()
                    .frame(width: 12, height: 12)

                Text("What’s New")
                    .font(.system(size: 12))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundColor(textColor)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(borderColor, lineWidth: 1)
            )
            .onTapGesture { showChangelog = true }
            .fullScreenCover(isPresented: $showChangelog) {
                WhatsNewScreen(
                    firmware: firmware,
                    state: state,
                    startUpdate: startUpdate
                )
            }
        }
    }
}

struct WhatsNewScreen: View {
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
        }
    }
}
