import Core
import Combine
import Inject
import SwiftUI

@MainActor
class InstructionViewModel: ObservableObject {
    @Inject private var appState: AppState
    private var handle: AnyCancellable?

    @Published var isConnected = false

    init() {
        handle = appState.$status
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                if $0 == .connected {
                    self?.isConnected = true
                }
            }
    }

    func openTermsOfService() {
        UIApplication.shared.open(.termsOfServiceURL)
    }

    func openPrivacyPolicy() {
        UIApplication.shared.open(.privacyPolicyURL)
    }
}
