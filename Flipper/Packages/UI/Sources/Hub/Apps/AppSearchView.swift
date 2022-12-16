import Core
import SwiftUI

struct AppSearchView: View {
    @EnvironmentObject var model: Applications
    @Environment(\.dismiss) var dismiss

    @State var predicate = ""

    var filteredItems: [Applications.Application] {
        guard !predicate.isEmpty else {
            return model.applications
        }
        return model.applications.filter {
            $0.name == predicate
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            if filteredItems.isEmpty {
                NothingFoundView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .customBackground(.background)
            } else {
                ScrollView {
                    AppList(applications: filteredItems)
                        .padding(14)
                }
                .customBackground(.background)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LeadingToolbarItems {
                BackButton {
                    dismiss()
                }
            }

            PrincipalToolbarItems {
                SearchField(
                    placeholder: "name, category, description",
                    predicate: $predicate
                )
                .offset(x: -10)
            }
        }
    }
}
