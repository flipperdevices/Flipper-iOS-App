import Core
import Combine
import Inject
import SwiftUI

@MainActor
class InstructionsViewModel: ObservableObject {
    private let appState: AppState = .shared
    private var disposeBag: DisposeBag = .init()

    @Published var presentConnectionsSheet = false
    @Binding var presentWelcomeSheet: Bool

    @Environment(\.presentationMode) var presentationMode

    init(_ presentWelcomeSheet: Binding<Bool>) {
        _presentWelcomeSheet = presentWelcomeSheet

        appState.$status
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                if $0 == .connected {
                    self?.presentConnectionsSheet = false
                    self?.presentWelcomeSheet = false
                }
            }
            .store(in: &disposeBag)
    }
}
