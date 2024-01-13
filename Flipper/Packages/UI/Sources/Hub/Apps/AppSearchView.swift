import Core
import SwiftUI

struct AppSearchView: View {
    @EnvironmentObject var model: Applications
    @Environment(\.dismiss) var dismiss

    @AppStorage(.hiddenApps) var hiddenApps: Set<String> = []

    @Binding var predicate: String
    var predicateIsValid: Bool {
        predicate.count >= 2
    }

    @State private var inProgress: Bool = false
    @State private var applications: [Applications.Application] = []
    @State private var error: Applications.Error?

    let debouncer = Debouncer(seconds: 1)

    var body: some View {
        VStack(spacing: 0) {
            if model.isOutdatedDevice {
                AppsNotCompatibleFirmware()
                    .padding(.horizontal, 14)
            } else if error != nil {
                AppsAPIError(error: $error, action: reload)
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
                } catch let error as Applications.Error {
                    self.error = error
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
