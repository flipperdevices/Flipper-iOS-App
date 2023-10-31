import SwiftUI
import Peripheral

extension RemoteControlView {
    struct DeviceControls: View {
        var action: (InputKey, Bool) -> Void

        var body: some View {
            HStack(alignment: .bottom, spacing: 36) {
                ControlCircle(action: action)
                ControlBackButton { action(.back, $0) }
            }
        }
    }

    struct ControlCircle: View {
        var action: @MainActor (InputKey, Bool) -> Void

        var verticalSpacing: Double { 12 }
        var horizontalSpacing: Double { 10 }

        var contentPadding: Double { 14 }

        var body: some View {
            Image("RemoteControlBackground")
                .overlay(
                    VStack(spacing: verticalSpacing) {
                        HStack(spacing: horizontalSpacing) {
                            ControlButton(inputKey: .up) {
                                action(.up, $0)
                            }
                        }

                        HStack(spacing: horizontalSpacing) {
                            ControlButton(inputKey: .left) {
                                action(.left, $0)
                            }
                            ControlButton(inputKey: .enter) {
                                action(.enter, $0)
                            }
                            ControlButton(inputKey: .right) {
                                action(.right, $0)
                            }
                        }

                        HStack(spacing: horizontalSpacing) {
                            ControlButton(inputKey: .down) {
                                action(.down, $0)
                            }
                        }
                    }
                )
        }
    }

    struct ControlButtonImage: View {
        let inputKey: InputKey

        var rotation: Double {
            switch inputKey {
            case .up: return 0
            case .left: return -90
            case .right: return 90
            case .down: return 180
            default: return 0
            }
        }

        var image: String {
            switch inputKey {
            case .up: return "RemoteControlArrow"
            case .down: return "RemoteControlArrow"
            case .left: return "RemoteControlArrow"
            case .right: return "RemoteControlArrow"
            case .enter: return "RemoteControlEnter"
            case .back: return "RemoteControlBack"
            }
        }

        init(_ inputKey: InputKey) {
            self.inputKey = inputKey
        }

        var body: some View {
            Image(image)
                .rotationEffect(.degrees(rotation))
        }
    }

    struct ControlButton: View {
        let inputKey: InputKey
        var action: (Bool) -> Void

        var body: some View {
            Button {
            } label: {
                ControlButtonImage(inputKey)
            }
            .simultaneousGesture(
                LongPressGesture()
                    .onEnded { _ in
                        action(true)
                    }
            )
            .highPriorityGesture(
                TapGesture()
                    .onEnded { _ in
                        action(false)
                    }
            )
        }
    }

    struct ControlEnterButton: View {
        var action: (Bool) -> Void

        var body: some View {
            Button {
            } label: {
                Image("RemoteControlEnter")
            }
            .simultaneousGesture(
                LongPressGesture()
                    .onEnded { _ in
                        action(true)
                    }
            )
            .highPriorityGesture(
                TapGesture()
                    .onEnded { _ in
                        action(false)
                    }
            )
        }
    }

    struct ControlBackButton: View {
        var action: (Bool) -> Void

        var body: some View {
            Button {
            } label: {
                Image("RemoteControlBack")
            }
            .simultaneousGesture(
                LongPressGesture()
                    .onEnded { _ in
                        action(true)
                    }
            )
            .highPriorityGesture(
                TapGesture()
                    .onEnded { _ in
                        action(false)
                    }
            )
        }
    }
}
