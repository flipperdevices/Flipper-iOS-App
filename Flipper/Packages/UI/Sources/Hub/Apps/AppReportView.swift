import Core
import SwiftUI

struct AppReportView: View {
    let application: Applications.Application

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) var dismiss

    @Environment(\.notifications) var notifications

    var backgroundColor: Color {
        switch colorScheme {
        case .light: return .black12
        default: return .black60
        }
    }

    var body: some View {
        List {
            NavigationListItem(image: "ListBug", title: "Report Bug") {
                AppIssueView(application: application)
            }

            NavigationListItem(image: "ListConcern", title: "Report Concern") {
                AppConcernView(application: application)
            }
        }
        .navigationBarBackground(Color.a1)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LeadingToolbarItems {
                BackButton {
                    dismiss()
                }
            }
            PrincipalToolbarItems(alignment: .leading) {
                Title("Report App")
            }
        }
        // TODO: why not? dreaming of NavigationStack
        .onChange(of: notifications.apps.showReported) { newValue in
            if newValue {
                dismiss()
            }
        }
    }
}

struct NavigationListItem<Destination: View>: View {
    let image: String
    let title: String

    var destination: () -> Destination

    init(
        image: String,
        title: String,
        @ViewBuilder destination: @escaping () -> Destination
    ) {
        self.image = image
        self.title = title
        self.destination = destination
    }

    var body: some View {
        HStack {
            Image(image)
                .renderingMode(.template)
            NavigationLink(title) {
                destination()
            }
        }
    }
}
