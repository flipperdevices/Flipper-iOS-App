import SwiftUI
import Peripheral

struct DeviceControls: View {
    var onButton: @MainActor (InputKey) -> Void

    var body: some View {
        HStack(alignment: .bottom, spacing: 36) {
            ControlCircle(onButton: onButton)
            ControlBackButton(onButton: onButton)
        }
    }
}

struct ControlCircle: View {
    var onButton: @MainActor (InputKey) -> Void

    var verticalSpacing: Double { 12 }
    var horizontalSpacing: Double { 10 }

    var contentPadding: Double { 14 }

    var body: some View {
        Image("RemoteControlBackground")
            .overlay(
                VStack(spacing: verticalSpacing) {
                    HStack(spacing: horizontalSpacing) {
                        ControlButton(inputKey: .up, onButton: onButton)
                    }

                    HStack(spacing: horizontalSpacing) {
                        ControlButton(inputKey: .left, onButton: onButton)
                        ControlButton(inputKey: .enter, onButton: onButton)
                        ControlButton(inputKey: .right, onButton: onButton)
                    }

                    HStack(spacing: horizontalSpacing) {
                        ControlButton(inputKey: .down, onButton: onButton)
                    }
                }
            )
    }
}

struct ControlButton: View {
    let inputKey: InputKey

    var onButton: @MainActor (InputKey) -> Void

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

    var body: some View {
        Button {
            onButton(inputKey)
        } label: {
            Image(image)
                .rotationEffect(.degrees(rotation))
        }
    }
}

struct ControlEnterButton: View {
    var onButton: @MainActor (InputKey) -> Void

    var body: some View {
        Button {
            onButton(.enter)
        } label: {
            Image("RemoteControlEnter")
        }
    }
}

struct ControlBackButton: View {
    var onButton: @MainActor (InputKey) -> Void

    var body: some View {
        Button {
            onButton(.back)
        } label: {
            Image("RemoteControlBack")
        }
    }
}
