import Core

import SwiftUI

extension InfraredView {
    struct InfraredChooseCategory: View {
        @EnvironmentObject private var infraredModel: InfraredModel

        @Environment(\.dismiss) private var dismiss
        @Environment(\.path) private var path

        @State private var categories: [InfraredCategory] = []
        @State private var error: InfraredModel.Error.Network?

        private let columns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]

        var body: some View {
            VStack(spacing: 0) {
                if let error {
                    InfraredNetworkError(error: error, action: retry)
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 12) {
                            if categories.isEmpty {
                                ForEach(1...8, id: \.self) { _ in
                                    CategoryPlaceholder()
                                }
                            } else {
                                ForEach(categories) { category in
                                    CategoryCard(item: category) {
                                        path.append(
                                            Destination.chooseBrand(category)
                                        )
                                    }
                                }
                            }
                        }
                        .padding(14)
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
                    Title("Select Device", description: "Step 1 of 3")
                }
            }
            .task {
                guard categories.isEmpty else { return }
                await loadCategories()
            }
        }

        private func loadCategories() async {
            do {
                categories = try await infraredModel.loadCategories()
            } catch let error as InfraredModel.Error.Network {
                self.error = error
            } catch {}
        }

        private func retry() {
            Task {
                error = nil
                categories = []
                await loadCategories()
            }
        }
    }
}
