import SwiftUI
import Peripheral

extension RemoteControlView {
    struct ControlsQueue: View {
        @Binding var controlsQueue: [(UUID, InputKey)]

        init(_ controlsQueue: Binding<[(UUID, InputKey)]>) {
            _controlsQueue = controlsQueue
        }

        var body: some View {
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(controlsQueue, id: \.0) { item in
                        KeyImage(item.1)
                    }
                }
                .frame(height: 18)
            }
            .disabled(true)
        }

        struct KeyImage: View {
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
                case .up: return "QueueUp"
                case .down: return "QueueUp"
                case .left: return "QueueUp"
                case .right: return "QueueUp"
                case .enter: return "QueueEnter"
                case .back: return "QueueBack"
                }
            }

            init(_ inputKey: InputKey) {
                self.inputKey = inputKey
            }

            var body: some View {
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .rotationEffect(.degrees(rotation))
            }
        }
    }
}
