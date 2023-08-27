import Core
import SwiftUI

struct AppSearchView: View {
    @EnvironmentObject var model: Applications
    @Environment(\.dismiss) var dismiss

    @AppStorage(.hiddenAppsKey) var hiddenApps: Set<String> = []

    @State private var predicate = ""
    var predicateIsValid: Bool {
        predicate.count >= 2
    }

    @State private var inProgress: Bool = false
    @State private var applications: [Applications.ApplicationInfo] = []
    @State private var apiError: Applications.APIError?

    let debouncer = Debouncer(seconds: 1)

    @FocusState var isSearchFieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            if model.isOutdatedDevice {
                AppsNotCompatibleFirmware()
                    .padding(.horizontal, 14)
            } else if apiError != nil {
                AppsAPIError(error: $apiError, action: reload)
                    .padding(.horizontal, 14)
            } else if !predicateIsValid {
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
                    predicate: $predicate,
                    isFocused: _isSearchFieldFocused
                )
                .offset(x: -10)
            }
        }
        .onChange(of: predicate) { newValue in
            search(for: newValue)
        }
    }

    func search(for string: String) {
        Task {
            guard string.count >= 2 else {
                await debouncer.cancel()
                applications = []
                return
            }
            inProgress = true
            await debouncer.submit {
                defer { inProgress = false }
                do {
                    applications = try await model.search(for: string).filter {
                        !self.hiddenApps.contains($0.id)
                    }
                } catch let error as Applications.APIError {
                    apiError = error
                } catch {
                    applications = []
                }
            }
        }
    }

    func reload() {
        search(for: predicate)
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
