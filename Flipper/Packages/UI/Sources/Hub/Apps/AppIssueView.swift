import Core
import SwiftUI

struct AppIssueView: View {
    let application: Applications.Application

    @Environment(\.openURL) var openURL
    @Environment(\.dismiss) var dismiss

    var instruction: AttributedString {
        var text: AttributedString = """
            1. Go to Issues on the main page of app repository.
            2. Create your issue with New issue button.
            (Try to describe the bug in detail with the playback steps. \
            This will help the developer to fix it faster).
            """

        text.font = .system(size: 14)

        if let range = text.range(of: "Issues") {
            text[range].font = .system(size: 14, weight: .bold)
        }

        if let range = text.range(of: "New issue") {
            text[range].font = .system(size: 14, weight: .bold)
        }

        return text
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(
                    "To report a bug, create an issue on GitHub or " +
                    "contact the developer"
                )
                .font(.system(size: 16))

                Image("GitHubIssueContent")
                    .resizable()
                    .scaledToFit()
                    .background(
                        Image("GitHubIssueBackground")
                            .resizable()
                            .scaledToFit()
                    )

                Text(instruction)

                UnderlinedURL(
                    image: "GitHub",
                    label: "Go to Repository",
                    url: application.current.links.github
                )
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 14)
        }
        .navigationBarBackground(Color.a1)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LeadingToolbarItems {
                BackButton {
                    dismiss()
                }
                Title("Report Bug")
            }
        }
    }
}
