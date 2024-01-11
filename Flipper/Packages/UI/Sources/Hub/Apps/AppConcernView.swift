import Core
import SwiftUI

struct AppConcernView: View {
    @EnvironmentObject var model: Applications

    let application: Applications.Application

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) var dismiss

    @State private var description = ""
    @State private var attachLogs = true
    @FocusState private var focusState: Focused?

    @Environment(\.notifications) var notifications

    enum Focused {
        case description
    }

    var placeholder: String {
        "Describe why are you reporting this app (enter at least 5 characters)"
    }

    var placeholderColor: Color {
        switch colorScheme {
        case .light: return .black12
        default: return .black60
        }
    }

    var showDescriptionPlaceholder: Bool {
        description.isEmpty && focusState != .description
    }

    var isValid: Bool {
        description.filter { !$0.isWhitespace }.count >= 5
    }

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .font(.system(size: 16, weight: .bold))

                ZStack(alignment: .topLeading) {
                    Text(placeholder)
                        .foregroundColor(placeholderColor)
                        .opacity(showDescriptionPlaceholder ? 1 : 0)
                        .padding(12)

                    TextEditor(text: $description)
                        .focused($focusState, equals: .description)
                        .hideScrollBackground()
                        .frame(minHeight: 100, maxHeight: 220)
                        .padding(12)
                }
                .font(.system(size: 14, weight: .medium))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(placeholderColor, lineWidth: 1)
                }

                Spacer()

                Button {
                    report()
                } label: {
                    Text("Submit")
                        .font(.system(size: 16, weight: .bold))
                        .frame(height: 47)
                        .frame(maxWidth: .infinity)
                        .background(isValid ? Color.a2 : .black30)
                        .cornerRadius(30)
                        .foregroundColor(.white)
                }
                .disabled(!isValid)
            }
            .padding(14)
        }
        .navigationBarBackground(Color.a1)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LeadingToolbarItems {
                BackButton {
                    dismiss()
                }
                Title("Report Abuse")
            }
        }
        .notification(isPresented: notifications.apps.showReported) {
            AppReportBanner()
        }
    }

    func report() {
        Task {
            do {
                try await model.report(application, description: description)
                dismiss()
                notifications.apps.showReported = true
            } catch {
                // TODO: show error
            }
        }
    }
}
