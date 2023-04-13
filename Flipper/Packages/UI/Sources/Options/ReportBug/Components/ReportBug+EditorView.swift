import SwiftUI

extension ReportBugView {
    struct EditorView: View {
        @Environment(\.colorScheme) private var colorScheme

        let onSubmit: (Report) -> Void

        @State private var title = ""
        @State private var description = ""
        @State private var attachLogs = true
        @FocusState private var focusState: Focused?

        enum Focused {
            case title
            case description
        }

        var placeholderColor: Color {
            switch colorScheme {
            case .light: return .black12
            default: return .black60
            }
        }

        var titlePlaceholder: String {
            "Describe your bug in one sentence"
        }

        var descriptionPlaceholder: String {
            """
            Describe your bug in details, with the playback steps, \
            expected result and your actual result.

            For example:
             1. Open App
             2. Connect Flipper
             3. Go to the Archive
             4. Go to Sub-GHz category

            Expected result: I see my Sub-GHz keys
            Actual result: App crashes
            """
        }

        var showTitlePlaceholder: Bool {
            title.isEmpty && focusState != .title
        }

        var showDescriptionPlaceholder: Bool {
            description.isEmpty && focusState != .description
        }

        var isValid: Bool {
            !title.isEmpty && !description.isEmpty
        }

        var titleView: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text("Title")
                    .font(.system(size: 16, weight: .bold))

                ZStack(alignment: .leading) {
                    Text(titlePlaceholder)
                        .foregroundColor(placeholderColor)
                        .opacity(showTitlePlaceholder ? 1 : 0)
                        .padding(12)

                    TextField("", text: $title)
                        .focused($focusState, equals: .title)
                        .submitLabel(.return)
                        .padding(12)
                }
                .font(.system(size: 14, weight: .medium))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(placeholderColor, lineWidth: 1)
                }
            }
        }

        var descriptionView: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .font(.system(size: 16, weight: .bold))

                ZStack(alignment: .topLeading) {
                    Text(descriptionPlaceholder)
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
            }
        }

        var submitButton: some View {
            Button {
                onSubmit(.init(
                    title: title,
                    description: description,
                    attachLogs: attachLogs))
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
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                GeometryReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            titleView

                            descriptionView

                            Toggle("Add logs", isOn: $attachLogs)
                                .tint(.a1)
                        }
                        .padding(14)
                        .padding(.bottom, proxy.safeAreaInsets.bottom)
                    }
                    .padding(.bottom, proxy.safeAreaInsets.bottom)
                }

                submitButton
                    .padding(14)
            }
            .ignoresSafeArea(.keyboard)
            .onTapGesture {
                focusState = nil
            }
        }
    }
}
