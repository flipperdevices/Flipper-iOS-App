import Core

import SwiftUI

extension InfraredView {
    struct InfraredChooseCategory: View {
        @EnvironmentObject private var infraredModel: InfraredModel

        @Environment(\.dismiss) private var dismiss
        @Environment(\.path) private var path

        @State private var categories: [InfraredCategory] = []

        @State private var isLoading: Bool = true
        @State private var isError: Bool = false

        private let columns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]

        var body: some View {
            VStack(spacing: 0) {
                if isLoading {
                    Spinner()
                } else if isError {
                    Text("Some Error on Load Category")
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(categories) { category in
                                CategoryCard(item: category) {
                                    path.append(
                                        Destination
                                            .infraredChooseBrand(category)
                                    )
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
                do {
                    guard categories.isEmpty else { return }
                    categories = try await infraredModel.loadCategories()
                    isLoading = false
                } catch {
                    isError = true
                }
            }
        }
    }

    struct CategoryCard: View {
        let item: InfraredCategory
        let onItemSelected: () -> Void

        private var uiImage: UIImage? {
            let data = Data(base64Encoded: item.image) ?? Data()
            return UIImage(data: data)
        }

        var body: some View {
            VStack(spacing: 8) {
                if let uiImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .frame(width: 36, height: 36)
                }

                Text(item.name)
                    .font(.system(size: 18, weight: .regular))
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(Color.groupedBackground)
            .cornerRadius(16)
            .shadow(color: .shadow, radius: 16, x: 0, y: 4)
            .onTapGesture { onItemSelected() }
        }
    }
}
