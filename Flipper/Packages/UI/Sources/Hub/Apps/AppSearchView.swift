import Core
import SwiftUI

struct AppSearchView: View {
    @EnvironmentObject var model: Applications
    @Environment(\.dismiss) var dismiss

    @State var predicate = ""
    var predicateIsValid: Bool {
        predicate.count >= 2
    }

    @State var inProgress: Bool = false
    @State var applications: [Applications.ApplicationInfo] = []

    let debouncer = Debouncer(seconds: 1)

    var body: some View {
        VStack(spacing: 0) {
            if !predicateIsValid {
                Placeholder()
            } else if inProgress {
                Spinner()
            } else if applications.isEmpty {
                NothingFound(query: predicate)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .customBackground(.background)
            } else {
                ScrollView {
                    AppList(applications: applications)
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
                    placeholder: "App name, description",
                    predicate: $predicate
                )
                .offset(x: -10)
            }
        }
        .onChange(of: predicate) { newValue in
            Task {
                guard newValue.count >= 2 else {
                    await debouncer.cancel()
                    applications = []
                    return
                }
                inProgress = true
                await debouncer.submit {
                    defer { inProgress = false }
                    do {
                        applications = try await model.search(for: newValue)
                    } catch {
                        applications = []
                    }
                }
            }
        }
    }

    struct Placeholder: View {
        var body: some View {
            VStack(spacing: 4) {
                Text("Enter at least 2 symbols")
                    .font(.system(size: 14, weight: .medium))

                Text("to search for some apps")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black40)
            }
        }
    }

    struct NothingFound: View {
        let query: String

        var body: some View {
            VStack(spacing: 4) {
                Text("No Results Found")
                    .font(.system(size: 14, weight: .medium))

                Text("for “\(query)”")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black40)
            }
        }
    }
}
