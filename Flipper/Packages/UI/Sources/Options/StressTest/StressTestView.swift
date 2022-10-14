import Core
import SwiftUI

struct StressTestView: View {
    @StateObject var viewModel: StressTestViewModel
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        VStack {
            HStack {
                Text("success: \(viewModel.successCount)")
                Text("error: \(viewModel.errorCount)")
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)

            List(viewModel.events.reversed()) {
                Text($0.message)
                    .foregroundColor($0.color)
            }

            HStack {
                Spacer()
                Button {
                    viewModel.start()
                } label: {
                    Text("Start")
                        .roundedButtonStyle(maxWidth: .infinity)
                }
                Spacer()
                Button {
                    viewModel.stop()
                } label: {
                    Text("Stop")
                        .roundedButtonStyle(maxWidth: .infinity)
                }
                Spacer()
            }
            .padding(.vertical, 20)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LeadingToolbarItems {
                BackButton {
                    presentationMode.wrappedValue.dismiss()
                }
                Title("Stress Test")
            }
        }
        .onDisappear {
            viewModel.stop()
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
