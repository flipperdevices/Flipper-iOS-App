import SwiftUI

extension ReportBugView {
    struct FailureView: View {
        @Environment(\.colorScheme) private var colorScheme

        var placeholderColor: Color {
            switch colorScheme {
            case .light: return .black16
            default: return .black60
            }
        }
        
        var text: Any = {
            if #available(iOS 15, *) {
                var source: AttributedString = """
                Unable to report bug from the app. Try again later or post \
                your bug on our forum so we can fix it faster. Here is the \
                instruction how to do it.

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
            } else {
                return """
                Unable to report bug from the app. Try again later or post \
                your bug on our forum so we can fix it faster.
                
                Check the bug in TestFlight app version. If it doesn’t \
                reproduce, then we have already fixed it.
                """
            }
        }()

        var body: some View {
            VStack(spacing: 0) {
                VStack(spacing: 12) {
                    Text("Report Failed")
                        .font(.system(size: 18, weight: .bold))

                    Image("ReportFailed")
                        .font(.system(size: 14, weight: .medium))
                }
                .padding(.top, 18)

                VStack(spacing: 18) {
                    if #available(iOS 15, *) {
                        Text(text as! AttributedString)
                    } else {
                        Text(text as! String)
                    }
                    
                }
                .padding(.top, 32)

                Spacer()
            }
            .padding(.top, 14)
            .padding(.horizontal, 14)
        }
    }
}
