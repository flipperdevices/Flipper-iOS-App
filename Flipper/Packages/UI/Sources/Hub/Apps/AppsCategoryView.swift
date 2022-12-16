import Core
import SwiftUI

struct AppsCategoryView: View {
    @EnvironmentObject var model: Applications
    @Environment(\.dismiss) var dismiss

    let category: Applications.Category

    var applications: [Applications.Application] {
        model.applications
        // model.applications.filter { application in
        //     application.category.id == category.id
        // }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                HStack {
                    Spacer()
                    SortMenu()
                }
                .padding(.horizontal, 14)

                AppList(applications: applications)
            }
            .padding(.vertical, 18)
        }
        .background(Color.background)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LeadingToolbarItems {
                BackButton {
                    dismiss()
                }

                Title(category.name)
                    .padding(.leading, 8)
            }
        }
    }
}
