import SwiftUI

extension ReportBugView {
    struct SuccessView: View {
        @Environment(\.colorScheme) private var colorScheme

        let id: String

        var placeholderColor: Color {
            switch colorScheme {
            case .light: return .black16
            default: return .black60
            }
        }

        var text: AttributedString = {
            var source: AttributedString = """
                You can also post your bug on our forum so we can fix it \
                faster. Here is the instruction how to do it.

                Check the bug in TestFlight app version. If it doesn’t \
                reproduce, then we have already fixed it.
                """

            source.foregroundColor = .black40

            guard let range = source.range(
                of: "Here is the instruction how to do it."
            ) else {
                return source
            }

            source[range].foregroundColor = .a2
            source[range].link = .bugReport
            source[range].underlineStyle = .single

            return source
        }()

        var issueID: some View {
            VStack(spacing: 4) {
                Text("Your issue ID:")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black40)

                HStack {
                    Text(id)
                        .lineLimit(1)

                    Spacer()

                    Button {
                        UIPasteboard.general.string = id
                    } label: {
                        Text("Copy")
                            .foregroundColor(.a2)
                    }
                }
                .font(.system(size: 14, weight: .medium))
                .padding(12)
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(placeholderColor, lineWidth: 1)
                }
            }
        }

        var body: some View {
            VStack(spacing: 0) {
                VStack(spacing: 12) {
                    Text("Report Successful")
                        .font(.system(size: 18, weight: .bold))

                    Image("ReportSuccessful")
                        .font(.system(size: 14, weight: .medium))
                }
                .padding(.top, 18)

                VStack(spacing: 18) {
                    issueID

                    Text(text)
                }
                .padding(.top, 32)

                Spacer()
            }
            .padding(.top, 14)
            .padding(.horizontal, 14)
        }
    }
}
