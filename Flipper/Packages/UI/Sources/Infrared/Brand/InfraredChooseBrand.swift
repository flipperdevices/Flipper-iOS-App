import Core

import SwiftUI

extension InfraredView {
    struct InfraredChooseBrand: View {
        @EnvironmentObject private var infraredModel: InfraredModel

        @Environment(\.dismiss) private var dismiss
        @Environment(\.path) private var path

        @State private var brands: [InfraredBrand] = []
        @State private var error: InfraredModel.Error.Network?

        @State private var predicate = ""
        @State private var isSearchableActive = false

        private var filteredBrands: [InfraredBrand] {
            if predicate.isEmpty {
                return brands
            } else {
                return brands.filter {
                    $0.name.lowercased().contains(predicate.lowercased())
                }
            }
        }

        let category: InfraredCategory

        var body: some View {
            VStack(spacing: 0) {
                if let error {
                    InfraredNetworkError(error: error, action: retry)
                } else if brands.isEmpty {
                    ChooseBrandPlaceholder()
                } else {
                    ListBrand(brands: filteredBrands) {
                        path.append(Destination.chooseSignal($0))
                    }
                    .searchable(
                        text: $predicate,
                        prompt: "Brand Name"
                    )
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
                guard brands.isEmpty else { return }
                await loadBrands()
            }
        }

        private func loadBrands() async {
            do {
                brands = try await infraredModel.loadBrand(category)
            } catch let error as InfraredModel.Error.Network {
                self.error = error
            } catch {}
        }

        private func retry() {
            Task {
                error = nil
                brands = []
                await loadBrands()
            }
        }
    }
}
