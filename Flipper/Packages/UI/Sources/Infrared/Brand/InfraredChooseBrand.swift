import Core

import SwiftUI

extension InfraredView {
    struct InfraredChooseBrand: View {
        @EnvironmentObject private var infraredModel: InfraredModel

        @Environment(\.dismiss) private var dismiss
        @Environment(\.path) private var path

        @State private var brands: [InfraredBrand] = []

        @State private var isLoading: Bool = true
        @State private var isError: Bool = false

        let category: InfraredCategory

        var body: some View {
            VStack(spacing: 0) {
                if isLoading {
                    Spinner()
                } else if isError {
                    Text("Some Error on Load Brands")
                } else {
                    InfraredListBrand(brands: brands) {
                        path.append(Destination.infraredChooseSignal($0))
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
                do {
                    guard brands.isEmpty else { return }
                    brands = try await infraredModel
                        .loadBrand(forCategoryID: category.id)
                    isLoading = false
                } catch {
                    isError = true
                }
            }
        }
    }
}
