import Core
import SwiftUI

struct AppReportView: View {
    @EnvironmentObject var model: Applications

    let application: Applications.Application

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) var dismiss

    @State private var description = ""
    @State private var attachLogs = true
    @FocusState private var focusState: Focused?

    enum Focused {
        case description
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
        !description.isEmpty
    }

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .font(.system(size: 16, weight: .bold))

                ZStack(alignment: .topLeading) {
                    Text("Describe why are you reporting this app")
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
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LeadingToolbarItems {
                BackButton {
                    dismiss()
                }
                Title("Report an App")
            }
        }
    }

    func report() {
        Task {
            do {
                try await model.report(application, description: description)
                dismiss()
            } catch {
                print("report an app: \(error)")
            }
        }
    }
}
