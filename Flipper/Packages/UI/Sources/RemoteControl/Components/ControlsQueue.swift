import SwiftUI
import Peripheral

extension RemoteControlView {
    struct ControlsQueue: View {
        @Binding var controlsQueue: [(UUID, Control)]

        init(_ controlsQueue: Binding<[(UUID, Control)]>) {
            _controlsQueue = controlsQueue
        }

        var body: some View {
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(controlsQueue, id: \.0) { item in
                        ControlImage(item.1)
                    }
                }
                .frame(height: 18)
            }
            .disabled(true)
        }

        struct ControlImage: View {
            let control: Control

            var rotation: Double {
                switch control {
                case .inputKey(.left): return -90
                case .inputKey(.right): return 90
                case .inputKey(.down): return 180
                default: return 0
                }
            }

            var image: String {
                switch control {
                case .lock: return "QueueLock"
                case .unlock: return "QueueUnlock"
                case .inputKey(.up): return "QueueUp"
                case .inputKey(.down): return "QueueUp"
                case .inputKey(.left): return "QueueUp"
                case .inputKey(.right): return "QueueUp"
                case .inputKey(.enter): return "QueueEnter"
                case .inputKey(.back): return "QueueBack"
                }
            }

            init(_ control: Control) {
                self.control = control
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
