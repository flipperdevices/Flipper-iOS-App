import Core
import Combine
import Inject
import Logging
import Foundation
import SwiftUI

public class RootViewModel: ObservableObject {
    private let logger = Logger(label: "root")

    let appState: AppState = .shared

    var disposeBag: DisposeBag = .init()

    @Published var isFirstLaunch: Bool
    @Published var isPairingIssue = false

    public init() {
        isFirstLaunch = appState.isFirstLaunch

        appState.$status
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self = self else {
                    return
                }
                if $0 == .invalidPairing {
                    withAnimation(.easeOut.speed(2)) {
                        self.isPairingIssue = true
                    }
                }
                if $0 == .connected || $0 == .unsupportedDevice {
                    self.appState.isFirstLaunch = false
                    self.hideWelcomeScreen()
                }
            }
            .store(in: &disposeBag)

        appState.$isFirstLaunch
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isFirstLaunch in
                guard let self = self else {
                    return
                }
                if self.isFirstLaunch != isFirstLaunch {
                    isFirstLaunch
                        ? self.showWelcomeScreen()
                        : self.hideWelcomeScreen()
                }
            }
            .store(in: &disposeBag)
    }

    func showWelcomeScreen() {
        isFirstLaunch = true
    }

    func hideWelcomeScreen() {
        withAnimation {
            self.isFirstLaunch = false
        }
    }

    func onOpenURL(_ url: URL) async {
        await appState.onOpenURL(url)
    }
}
