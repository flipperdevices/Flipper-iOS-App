import Core
import SwiftUI

struct AppsCategoryView: View {
    @EnvironmentObject var model: Applications
    @Environment(\.dismiss) var dismiss

    let category: Applications.Category

    @State var applications: [Applications.Application] = []

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
        .task {
            await load()
        }
        .onReceive(model.$sortOrder) { newValue in
            Task {
                await load()
            }
        }
    }

    func load() async {
        do {
            applications = try await model.loadApplications(for: category)
        } catch {
            applications = []
        }
    }
}
