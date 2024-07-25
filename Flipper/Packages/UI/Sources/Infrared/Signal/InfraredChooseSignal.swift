import Core

import SwiftUI

struct InfraredChooseSignal: View {
    @EnvironmentObject private var infraredModel: InfraredModel

    @Environment(\.dismiss) private var dismiss
    @Environment(\.path) private var path

    @State private var isLoading: Bool = true
    @State private var signal: InfraredSignal?

    @State private var successControls: [Int] = []
    @State private var failureControls: [Int] = []

    let brand: InfraredBrand

    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                Spinner()
            } else if let signal {
                VStack(alignment: .center, spacing: 14) {
                    Spacer()
                    InfraredButtonTypeView(data: signal.button)
                        .frame(width: 60, height: 60)
                    Text("Point Flipper at the TV and tap the button")
                        .font(.system(size: 14, weight: .medium))
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackground(Color.a1)
        .toolbar {
            LeadingToolbarItems {
                BackButton {
                    dismiss()
                }
            }
            PrincipalToolbarItems {
                Title("Set Up Remote", description: "Step 3 of 3")
            }
        }
        .task {
            do {
                signal = try await infraredModel
                    .loadSignal(
                        brand: brand,
                        successControls: successControls,
                        failureControls: failureControls
                    )
                isLoading = false
            } catch {
                print("load signal \(brand) \(error)")
            }
        }
    }
}
