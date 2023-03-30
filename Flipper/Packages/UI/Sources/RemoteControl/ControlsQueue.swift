import SwiftUI
import Peripheral

struct ControlsQueue: View {
    @Binding var controlsQueue: [(UUID, InputKey)]

    init(_ controlsQueue: Binding<[(UUID, InputKey)]>) {
        _controlsQueue = controlsQueue
    }

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                ForEach(controlsQueue, id: \.0) { item in
                    ControlButtonImage(item.1)
                        .scaleEffect(0.7)
                        .opacity(0.7)
                }
                Spacer()
            }
            .frame(height: 40)
        }
        .disabled(true)
    }
}
