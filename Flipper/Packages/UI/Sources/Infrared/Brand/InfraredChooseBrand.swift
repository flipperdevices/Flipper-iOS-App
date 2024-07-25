import Core

import SwiftUI

struct InfraredChooseBrand: View {
    @EnvironmentObject private var infraredModel: InfraredModel

    @Environment(\.dismiss) private var dismiss
    @Environment(\.path) private var path

    @State public var isLoading: Bool = true

    private var brands: [InfraredBrand] {
        infraredModel.brands[category.id] ?? []
    }

    let category: InfraredCategory

    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                Spinner()
            } else {
                InfraredListBrand(brands: brands) {
                    navigationToSignal($0)
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
                Title("Select Brand", description: "Step 2 of 3")
            }
        }
        .task {
            await infraredModel.loadBrand(forCategoryID: category.id)
            isLoading = false
        }
    }

    private func navigationToSignal(_ brand: InfraredBrand) {
        let destination = OptionsView
            .Destination
            .infraredChooseLayout(brand)
        path.append(destination)
    }
}
