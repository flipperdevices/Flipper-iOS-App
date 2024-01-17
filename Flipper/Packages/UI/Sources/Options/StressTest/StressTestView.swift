import Core
import SwiftUI

struct StressTestView: View {
    // next step
    @StateObject var stressTest: StressTest = .init(
        pairedDevice: Dependencies.shared.pairedDevice
    )
    @Environment(\.dismiss) private var dismiss

    @State private var events: [StressTest.Event] = []

    var successCount: Int {
        events.filter { $0.kind == .success }.count
    }

    var errorCount: Int {
        events.filter { $0.kind == .error }.count
    }

    var body: some View {
        VStack {
            HStack {
                Text("success: \(successCount)")
                Text("error: \(errorCount)")
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)

            List(events.reversed()) {
                Text($0.message)
                    .foregroundColor($0.color)
            }

            HStack {
                Spacer()
                Button {
                    stressTest.start()
                } label: {
                    Text("Start")
                        .roundedButtonStyle(maxWidth: .infinity)
                }
                Spacer()
                Button {
                    stressTest.stop()
                } label: {
                    Text("Stop")
                        .roundedButtonStyle(maxWidth: .infinity)
                }
                Spacer()
            }
            .padding(.vertical, 20)
        }
        .navigationBarBackground(Color.a1)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LeadingToolbarItems {
                BackButton {
                    dismiss()
                }
            }
            PrincipalToolbarItems(alignment: .leading) {
                Title("Stress Test")
            }
        }
        .onDisappear {
            stressTest.stop()
        }
        .onReceive(stressTest.progress) {
            events = $0
        }
    }
}

extension StressTest.Event {
    var color: Color {
        switch kind {
        case .info: return .primary
        case .debug: return .secondary
        case .success: return .sGreen
        case .error: return .sRed
        }
    }
}

extension StressTest.Event: CustomStringConvertible {
    public var description: String {
        "[\(self.kind)] \(self.message)"
    }
}
