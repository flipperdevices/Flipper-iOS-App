import Core

import SwiftUI

struct InfraredChooseCategory: View {
    @EnvironmentObject private var infraredModel: InfraredModel

    @Environment(\.dismiss) private var dismiss
    @Environment(\.path) private var path

    @State public var isLoading: Bool = true

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                Spinner()
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(infraredModel.categories) { category in
                            CategoryCard(item: category)
                                .onTapGesture { navigationToBrand(category) }
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
            await infraredModel.loadCategories()
            isLoading = false
        }
    }

    private func navigationToBrand(_ category: InfraredCategory) {
        let destination = OptionsView
            .Destination
            .infraredChooseBrand(category)
        path.append(destination)
    }
}

extension InfraredChooseCategory {
    struct CategoryCard: View {
        let item: InfraredCategory

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
        }
    }
}
